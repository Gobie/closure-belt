fs = require 'fs'
through2 = require 'through2'

module.exports = (options) ->
  through2.obj (chunk, enc, cb) ->
    try
      fs.writeFileSync chunk.path, chunk.contents
    catch err
      return cb err
    cb null, chunk