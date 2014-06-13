_ = require 'lodash'
async = require 'async'

{hash} = require '../../shared/utils/'
{Message} = require '../../shared/db/schemas/'

options =
    new: true
    upsert: true

module.exports = (message, callback) ->
    message = _.omit(message, 'Name', 'Country')
    messageHash = hash(message)
    message.hash = messageHash
    Message.findOneAndUpdate({hash: messageHash}, message, options, callback)
