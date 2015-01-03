through2 = require 'through2'

module.exports = (options) ->
  through2.obj (chunk, enc, cb) ->
    cb null,
      path: options.path
      contents: chunk.toString()
