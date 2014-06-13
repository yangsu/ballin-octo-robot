_ = require 'lodash'
async = require 'async'
ProgressBar = require 'progress'

secret = require './secret'

imports =
    messages: require './messages/'
    calls: require './calls/'

options =
    readParallelLimit: 20
    saveParallelLimit: 5

async.series
    calls: async.apply(imports.calls, secret.calls.dir, options)
    messages: async.apply(imports.messages, secret.messages.dir, options)
, (e, d) ->
    if e?
        console.trace(e)
    else
        # return console.log d

