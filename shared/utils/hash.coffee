_ = require 'lodash'
crypto = require('crypto')

encodeUTF8 = (str) -> unescape(encodeURIComponent(str))
hash = (str) ->
    encoded = encodeUTF8(str)
    crypto.createHash('md5').update(encoded).digest('hex')

memoizedHash = _.memoize(hash)

sortObj = (obj) ->
    keys = _.keys(obj).sort()
    _.pick(obj, keys...)

module.exports = (obj) ->
    console.log JSON.stringify(sortObj(obj))
    memoizedHash(JSON.stringify(sortObj(obj)))

