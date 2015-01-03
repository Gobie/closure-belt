through2 = require 'through2'
optionsHelper = require '../utils/options-helper'

module.exports = optionsHelper {}, (options, filePath) ->
  through2.obj (chunk, enc, cb) ->
    cb null,
      path: filePath
      contents: chunk.toString()
