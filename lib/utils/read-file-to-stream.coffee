fs = require 'fs'
es = require 'event-stream'

module.exports = (filePath) ->
  stream = fs.createReadStream filePath
  stream = stream.pipe es.wait()
  stream