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
    ], callback
