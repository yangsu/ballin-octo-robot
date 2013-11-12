Backbone = require 'backbone'

exports = exports ? this

exports.Message = class Name extends Backbone.Model
    initialize: (data) ->
        # console.log data['Phone Number']
        # peopleInvolved[] = true
        # row.Date = moment(row.Date).unix()
    parse: ->
        console.log 'test'
