fs = require 'fs'

_ = require 'lodash'
csv = require 'csv'
moment = require 'moment'

secret = require '../secret'
{parseCalls} = require './parseCalls'

file = secret.calls.file

rows = parseCalls file

console.log rows
