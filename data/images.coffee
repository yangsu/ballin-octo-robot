_ = require 'lodash'
async = require 'async'
fs = require 'fs'

Importer = require './importer'

{Message} = require '../shared/db/schemas/'
{hash} = require '../shared/utils/'

class ImagesImporter extends Importer
    name: 'Images Importer'

    filter: (file, i) -> i < 1

    parse: (file, callback) ->
        async.waterfall [
            async.apply(fs.stat, file)
            (stat, cb) ->
                try
                    cb(null, {
                        size: stat.size,
                        modified: stat.mtime,
                        file
                    })
                catch e
                    cb(e)
        ], callback

    save: (image, callback) ->
        date = new Date('2012-03-14T13:17:04Z')
        query = {Attachments: {$ne: ''}, Date: date}
        console.log query
        async.waterfall [
            (cb) -> Message.find(query, cb)
            (results, cb) ->
                _.each results, (result) ->
                    omitted = _.omit(result.toObject(), '_id', 'hash')
                    console.log hash(omitted), result.hash
                # console.log results
        ], callback

module.exports = ImagesImporter
