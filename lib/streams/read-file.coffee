fs = require 'fs'
through2 = require 'through2'

module.exports = (streamOptions) ->
  (globalOptions, filePath) ->
    through2.obj (chunk, enc, cb) ->
      @_content ?= ''
      @_content += chunk.toString()
      cb()
    , (cb) ->
      @push
        path: filePath
        content: @_content
      cb()