through2 = require 'through2'
escapeRegexp = require 'escape-regexp'
_ = require 'lodash-node'
optionsHelper = require '../utils/options-helper'

module.exports = optionsHelper {}, (options, filePath) ->
  through2.obj (chunk, enc, cb) ->
    return cb new Error 'no dependencies in stream' unless chunk.dependencies

    chunk.unnecessary_requires = {}
    for namespace, value of chunk.dependencies.requires
      regex = new RegExp "^" + escapeRegexp(namespace)
      unless _.findKey(chunk.dependencies.uses, (_, key) -> regex.test key)
        chunk.unnecessary_requires[namespace] = value

    cb null, chunk
