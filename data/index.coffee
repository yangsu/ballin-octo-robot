_ = require 'lodash'
async = require 'async'
ProgressBar = require 'progress'

messages = require './messages/'
secret = require './secret'

dir = secret.messages.dir

imports = {messages}

schemas = require '../shared/db/schemas/'

parallelLimit = 20

saveMessage = (message, progressBar, onSave) ->
    message = _.omit(message, 'Name', 'Country')
    async.waterfall [
        (cb) -> schemas.Message.findOneAndUpdate(message, message, {new: true, upsert: true}, cb)
        (message, cb) ->
            progressBar.tick()
            cb(null, message)
    ], onSave

messagesPipeline = (done) ->
    async.waterfall [
        async.apply(imports.messages, dir, {parallelLimit})

        (messagesByFilename, updated) ->
            totalMessageCount = _.chain(messagesByFilename).values().flatten().value().length
            progressBar = new ProgressBar('saving messages [:bar] :current/:total (:percent)', {
                width: 50
                total: totalMessageCount
            })

            updateRequestsPerFile = _.reduce messagesByFilename, (memo, messages, filename) ->
                updateRequestsPerMessage = _.map messages, (message, i) ->
                    async.apply(saveMessage, message, progressBar)
                memo[filename] = (cb) ->
                    async.parallelLimit(updateRequestsPerMessage, parallelLimit, cb)
                memo
            , {}
            async.series(updateRequestsPerFile, updated)

    ], done

async.parallel
    messages: messagesPipeline
, (e, d) ->
    if e?
        console.trace(e)
    else
        return console.log d

