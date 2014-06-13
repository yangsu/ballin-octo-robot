csv = require 'csv'

module.exports = (file, callback) ->
    csv()
        .from.path(file, columns: true)
        .transform((row, index) -> row)
        .to.array (arr) ->
            callback(null, arr)
        .on('error', callback)
