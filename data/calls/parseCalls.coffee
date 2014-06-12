fs = require 'fs'

_ = require 'lodash'
csv = require 'csv'

exports = exports ? this

parseLine = (line) -> _.compact line.split /\s{2,}/

parseRow = (headers) -> (row) ->
    _.chain(headers)
        .zip(parseLine(row))
        .object()
        .value()

exports.parseCalls = (file) ->
    contents = fs.readFileSync file, 'utf-8'
    lines = _.compact contents.split '\n'

    headers = parseLine _.first lines
    parseRowFunc = parseRow headers

    rows = _.map _.rest(lines), parseRowFunc

    rows
