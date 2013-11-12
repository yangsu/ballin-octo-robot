fs = require 'fs'
path = require 'path'

_ = require 'lodash'
async = require 'async'
csv = require 'csv'
moment = require 'moment'

secret = require '../secret'
{Messages} = require './messages'

dir = secret.messages.dir
files = fs.readdirSync dir

files = files.slice 10, 16

messages = []

readReqs = _.reduce files, ((memo, file) ->
    memo[file] = (cb) ->
        ms = new Messages
        csv()
            .from.path(path.resolve(dir, file), columns: true)
            .to.array((rows) ->
                ms.reset(rows, parse:true))
            .on('end', (count) -> cb(null, ms))
            .on('error', (err) -> cb(null, ms))
    memo)
, {}

console.time 'read'
async.parallel readReqs, (err, data) ->
    console.timeEnd 'read'
    console.log _.keys(data).length
    if err
        console.log err
    else
        _.each data, (ms, i) ->
            # console.log ms.get 1366416725
            console.log ms.getTimestamps()
