fs = require 'fs'
through2 = require 'through2'

module.exports = (filePath) ->
  stream = fs.createReadStream filePath
  stream.pipe through2 (chunk, enc, cb) ->
    @_content ?= ''
    @_content += chunk.toString()
    cb()
  , (cb) ->
    @push @_content
    cb()
