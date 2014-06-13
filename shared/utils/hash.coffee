_ = require 'lodash'
crypto = require('crypto')

encodeUTF8 = (str) -> unescape(encodeURIComponent(str))
hash = (str) ->
    encoded = encodeUTF8(str)
    crypto.createHash('md5').update(encoded).digest('hex')

memoizedHash = _.memoize(hash)

module.exports = (obj) -> memoizedHash(JSON.stringify(obj))

