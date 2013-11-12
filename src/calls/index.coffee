fs = require 'fs'

_ = require 'lodash'
csv = require 'csv'
moment = require 'moment'

secret = require '../secret'
{parseCalls} = require './parseCalls'

file = secret.calls.file

rows = parseCalls file

# console.log rows

console.log _.chain(rows)
    .groupBy('Number')
    .each((calls, number) ->
        times = _.chain(calls)
            .pluck('Date')
            .map((date) -> moment(date))
            .sortBy((date) -> date.unix())
            .value()
        calls.splice.apply(calls, [0, calls.length].concat([number, times.length, _.last(times).fromNow()]))
    )
    .sortBy(1)
    .reverse()
    .value()
