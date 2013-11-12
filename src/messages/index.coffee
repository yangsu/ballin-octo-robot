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

files = files.slice 0, 10

messages = []

# key moment.unix(date.unix())

readReqs = {}
for file in files
    readReqs[file] = (cb) ->
        ms = new Messages
        csv()
            .from.path(path.resolve(dir, file), columns: true)
            .to.array((rows) -> ms.reset(rows))
            .on('end', (count) -> cb(null, ms))
            .on('error', (err) -> cb(null, ms))


console.time 'read'
async.parallel readReqs, (err, data) ->
    console.timeEnd 'read'
    console.log _.keys(data).length
    if err
        console.log err
    else
        # console.log data
        _.each data, (ms, i) ->
            console.log ms.getPhoneNumbers()
