fs = require 'fs'
through2 = require 'through2'
optionsHelper = require '../utils/options-helper'

module.exports = optionsHelper {}, (options, filePath) ->
  through2.obj (chunk, enc, cb) ->
    try
      fs.writeFileSync chunk.path, chunk.content
    catch err
      return cb err
    cb null, chunk