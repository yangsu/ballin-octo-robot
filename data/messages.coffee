_ = require 'lodash'
async = require 'async'
csv = require 'csv'
fs = require 'fs'
moment = require 'moment'

Importer = require './importer'
{Message} = require '../shared/db/schemas/'
{hash} = require '../shared/utils/'

options =
    new: true
    upsert: true

class MessagesImporter extends Importer
    name: 'Messages Importer'
    extension: 'csv'

    parse: (file, callback) ->
        async.waterfall [
            (cb) ->
                csv().from.path(file, columns: true)
                    .transform((row, index) -> row)
                    .to.array (arr) -> cb(null, arr)
                    .on('error', cb)
            (rows, cb) ->
                transformed = _.map rows, (row) -> _.omit(row, 'Name', 'Country')
                cb(null, transformed)
        ], callback


    save: (message, callback) ->
        messageHash = hash(message)
        message.hash = messageHash
        Message.findOneAndUpdate({hash: messageHash}, message, options, callback)

module.exports = MessagesImporter
