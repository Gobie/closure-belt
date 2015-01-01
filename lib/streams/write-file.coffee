fs = require 'fs'
through2 = require 'through2'

module.exports = () ->
  through2.obj (chunk, enc, cb) ->
    try
      fs.writeFileSync chunk.path, chunk.content
    catch err
      return cb err
    cb null, chunk