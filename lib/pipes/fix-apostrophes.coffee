module.exports = ->
  regex = /(goog\.(?:require|provide)\(?\s*)"((?:goog|an|este)(?:\.\w+)+)"/
  (data, cb) ->
    data = data.replace regex, (_0, call, namespace) ->
      return "#{call}'#{namespace}'"
    cb null, data