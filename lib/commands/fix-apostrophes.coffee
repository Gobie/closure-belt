es = require 'event-stream'
fixApostrophes = require '../pipes/fix-apostrophes'
readFile = require '../utils/read-file-to-stream'

module.exports = (filePath) ->
  stream = readFile filePath
  stream = stream.pipe es.map fixApostrophes()
  stream