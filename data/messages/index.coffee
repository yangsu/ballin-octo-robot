fs = require 'fs'
path = require 'path'
_ = require 'lodash'
async = require 'async'
csv = require 'csv'
ProgressBar = require 'progress'

generateCSVReadTasks = (dir, files, progressBar) ->
    _.reduce files, (memo, file) ->
        memo[file] = (cb) ->
            csv()
                .from.path(path.resolve(dir, file), columns: true)
                .transform((row, index) -> row)
                .to.array (arr) ->
                    progressBar.tick()
                    cb(null, arr)
                .on('error', cb)
        memo
    , {}

normalizeFilename = (filename) -> filename.replace(/\(\d\)\.csv/, '')
dedupMessages = (messagesByFilename) ->
    filenameGroups = _.chain(messagesByFilename)
        .keys()
        .groupBy(normalizeFilename)
        .values()
        .value()
    _.reduce filenameGroups, (memo, group) ->
        key = normalizeFilename(group[0])
        messagesInGroups = _.chain(messagesByFilename)
            .pick(group...)
            .values()
            .flatten()
            .value()
        uniqueMessages = _.uniq messagesInGroups, (message) -> JSON.stringify(message)
        memo[key] = uniqueMessages
        memo
    , {}


module.exports = (dir, options, callback) ->
    parallelLimit = options?.parallelLimit ? 20
    fileFilter = options?.filter ? _.identity
    async.waterfall [
        async.apply(fs.readdir, dir)
        (files, cb) ->
            csvs = _.filter(files, (file) -> /\.csv$/.test(file))
            filtered = _.filter(csvs, fileFilter)
            progressBar = new ProgressBar('reading csvs [:bar] :current/:total (:percent)', {
                width: 50
                total: filtered.length
            })
            readTasks = generateCSVReadTasks(dir, filtered, progressBar)
            async.parallelLimit(readTasks, parallelLimit, cb)
        (messagesByFilename, cb) ->
            console.log 'Deduping messages...'
            try
                cb(null, dedupMessages(messagesByFilename))
            catch e
                cb(e)
    ], callback
