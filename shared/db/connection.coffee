mongoose = require 'mongoose'
{db} = require '../config'

mongoose.connect("mongodb://localhost/#{db}")

module.exports = mongoose
