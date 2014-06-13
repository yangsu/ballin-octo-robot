_ = require 'lodash'

hash = require './hash'
utils = {hash}
_.extend(utils, require './aliases')

module.exports = utils
