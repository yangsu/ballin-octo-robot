Backbone = require 'backbone'
moment = require 'moment'

exports = exports ? this

exports.Message = class Name extends Backbone.Model
    idAttribute: 'timestamp'
    initialize: (data) ->

    parse: (data) ->
        data.timestamp = moment(data.Date).unix()
        data
