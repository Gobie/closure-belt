through2 = require 'through2'
coffee = require 'coffee-script'
optionsHelper = require '../utils/options-helper'

module.exports = optionsHelper {}, (options, filePath) ->
  through2.obj (chunk, enc, cb) ->
    try
      chunk.ast = coffee.nodes chunk.contents
    catch err
      return cb err
    cb null, chunk