_ = require 'lodash-node'
escape = require '../utils/escape-for-regex'

module.exports = ->
  (data, cb) ->
    data['unnecessary'] = {}
    for namespace, value of data['requires']
      regex = new RegExp "^" + escape(namespace)
      unless _.findKey(data['namespaces'], (_value, key) -> !!key.match regex)
        data['unnecessary'][namespace] = value

    cb null, data
