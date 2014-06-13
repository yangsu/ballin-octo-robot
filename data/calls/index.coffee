_ = require 'lodash'
async = require 'async'
fs = require 'fs'
path = require 'path'
ProgressBar = require 'progress'

parse = require './parse'
save = require './save'
{hash} = require '../../shared/utils/'

module.exports = (dir, options, callback) ->
    async.waterfall [
        async.apply(fs.readdir, dir)

        (files, readComplete) ->
            callLogs = _.filter(files, (file) -> /\.txt$/.test(file))
            progressBar = new ProgressBar('reading calls [:bar] :current/:total (:percent)', {
                width: 50
                total: callLogs.length
            })

            readTasks = _.map callLogs, (file) -> (cb) ->
                progressBar.tick()
                parse(path.resolve(dir, file), cb)

            async.parallelLimit(readTasks, options?.readParallelLimit, readComplete)

        (calls, saveComplete) ->
            uniqueCalls = _.chain(calls).flatten().uniq(hash).value()
            progressBar = new ProgressBar('saving calls [:bar] :current/:total (:percent)', {
                width: 50
                total: uniqueCalls.length
            })

            saveTasks = _.map uniqueCalls, (call) -> (cb) ->
                progressBar.tick()
                save(call, cb)

            async.parallelLimit(saveTasks, options?.saveParallelLimit, saveComplete)

    ], callback
