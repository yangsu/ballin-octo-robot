fs = require 'fs'
_ = require 'lodash'
async = require 'async'

parseLine = (line) -> _.compact line.split /\s{2,}/

parseRow = (headers) -> (row) ->
    _.chain(headers)
        .zip(parseLine(row))
        .object()
        .value()

module.exports = (file, callback) ->
    async.waterfall [
        async.apply(fs.readFile, file, 'utf-8')
        (contents, cb) ->
            try
                lines = _.compact contents.split '\n'
                headers = parseLine _.first lines
                parseRowFunc = parseRow headers
                rows = _.map _.rest(lines), parseRowFunc
                cb(null, rows)
            catch e
                cb(e)
    ], callback
