_ = require 'lodash'
async = require 'async'

{hash} = require '../../shared/utils/'
schemas = require '../../shared/db/schemas/'

options =
    new: true
    upsert: true

module.exports = (call, callback) ->
    callHash = hash(call)
    call.hash = callHash
    schemas.Call.findOneAndUpdate({hash: callHash}, call, options, callback)
