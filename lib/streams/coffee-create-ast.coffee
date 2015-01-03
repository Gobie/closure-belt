through2 = require 'through2'
coffee = require 'coffee-script'

module.exports = (options) ->
  through2.obj (chunk, enc, cb) ->
    try
      chunk.ast = coffee.nodes chunk.contents
    catch err
      return cb err
    cb null, chunk