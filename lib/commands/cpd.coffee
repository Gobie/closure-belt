jscpd = require 'jscpd'
_ = require 'lodash-node'

module.exports = (options) ->
  options = _.defaults options, path: __dirname
  jscpd::run options