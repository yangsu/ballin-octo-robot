_ = require 'lodash'
async = require 'async'
fs = require 'fs'
moment = require 'moment'

Importer = require './importer'
{Call} = require '../shared/db/schemas/'
{hash} = require '../shared/utils/'

parseLine = (line) -> _.compact line.split /\s{2,}/

parseRow = (headers) -> (row) ->
    _.chain(headers)
        .zip(parseLine(row))
        .object()
        .value()

transformRow = (row) ->
    transformedRow = _.omit row, 'Call Type', 'Duration'
    transformedRow.Type = row['Call Type']
    transformedRow.Duration = moment.duration(row['Duration']).asMilliseconds()
    transformedRow

options =
    new: true
    upsert: true

class CallsImporter extends Importer
    name: 'Calls Importer'
    extension: /\.txt$/

    parse: (file, callback) ->
        async.waterfall [
            async.apply(fs.readFile, file, 'utf-8')
            (contents, cb) ->
                try
                    lines = _.compact contents.split '\n'
                    headers = parseLine _.first lines
                    parseRowFunc = parseRow headers
                    rows = _.map _.rest(lines), parseRowFunc
                    transformed = _.map rows, transformRow
                    cb(null, transformed)
                catch e
                    cb(e)
        ], callback

    save: (call, callback) ->
        callHash = hash(call)
        call.hash = callHash
        Call.findOneAndUpdate({hash: callHash}, call, options, callback)

module.exports = CallsImporter
