through2 = require 'through2'
coffee = require 'coffee-script'

module.exports = (streamOptions) ->
  (globalOptions, filePath) ->
    through2.obj (chunk, enc, cb) ->
      try
        chunk.ast = coffee.nodes chunk.content
      catch err
        return cb err
      cb null, chunk