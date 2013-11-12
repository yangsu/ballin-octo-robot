_ = require 'lodash'
Backbone = require 'backbone'
{Message} = require './message'

exports = exports ? this

exports.Messages = class Messages extends Backbone.Collection
    model: Message
    initialize: (data) ->
    getPeopleInvolved: -> _.uniq @pluck 'Name'
    getTimestamps: ->
        dictionary = {}
        phoneNumbers = @getPeopleInvolved()
        dictionary[pn] = [] for pn in phoneNumbers

        @map (message) ->
            dictionary[message.get('Name')].push message.get('timestamp')

        _.each dictionary, (timestamps, key) -> timestamps.sort()

        dictionary

