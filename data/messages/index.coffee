_ = require 'lodash'
async = require 'async'
fs = require 'fs'
path = require 'path'
ProgressBar = require 'progress'

parse = require './parse'
save = require './save'
{hash} = require '../../shared/utils/'

module.exports = (dir, options, callback) ->
    fileFilter = options?.filter ? _.identity

    async.waterfall [
        async.apply(fs.readdir, dir)

        (files, readComplete) ->
            csvs = _.filter(files, (file) -> /\.csv$/.test(file))
            filtered = _.filter(csvs, fileFilter)
            progressBar = new ProgressBar('reading messages [:bar] :current/:total (:percent)', {
                width: 50
                total: filtered.length
            })

            readTasks = _.map filtered, (file) -> (cb) ->
                progressBar.tick()
                parse(path.resolve(dir, file), cb)

            async.parallelLimit(readTasks, options?.readParallelLimit, readComplete)

        (messages, saveComplete) ->
            uniqueMessages = _.chain(messages).flatten().uniq(hash).value()

            progressBar = new ProgressBar('saving messages [:bar] :current/:total (:percent)', {
                width: 50
                total: uniqueMessages.length
            })

            saveTasks = _.map uniqueMessages, (message) -> (cb) ->
                progressBar.tick()
                save(message, cb)

            async.parallelLimit(saveTasks, options?.saveParallelLimit, saveComplete)


    ], callback
