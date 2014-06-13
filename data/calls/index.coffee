fs = require 'fs'
path = require 'path'
_ = require 'lodash'
async = require 'async'
parse = require './parse'

generateReadTasks = (dir, files) ->
    _.reduce files, (memo, file) ->
        memo[file] = async.apply(parse, path.resolve(dir, file))
        memo
    , {}

module.exports = (dir, options, callback) ->
    async.waterfall [
        async.apply(fs.readdir, dir)
        (files, cb) ->
            parallelLimit = options?.parallelLimit ? 20
            calllogs = _.filter(files, (file) -> /\.txt$/.test(file))
            readTasks = generateReadTasks(dir, calllogs)
            async.parallelLimit(readTasks, parallelLimit, cb)
    ], callback
