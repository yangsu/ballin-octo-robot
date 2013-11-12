_ = require 'lodash'
Backbone = require 'backbone'
{Message} = require './message'

exports = exports ? this

exports.Messages = class Messages extends Backbone.Collection
    model: Message
    initialize: (data) ->
    getPhoneNumbers: ->
        _.uniq @pluck 'Phone Number'
