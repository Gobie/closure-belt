through2 = require 'through2'
optionsHelper = require '../utils/options-helper'

module.exports = optionsHelper {}, (options, filePath) ->
  through2.obj (chunk, enc, cb) ->
    @_content ?= ''
    @_content += chunk.toString()
    cb()
  , (cb) ->
    @push
      path: filePath
      content: @_content
    cb()