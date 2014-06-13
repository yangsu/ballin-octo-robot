mongoose = require 'mongoose'
{db} = require '../config'

console.info "connecting to #{db}"
mongoose.connect("mongodb://localhost/#{db}")

module.exports = mongoose
