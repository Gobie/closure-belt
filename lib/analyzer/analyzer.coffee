es = require 'event-stream'
missingRequires = require './../pipes/missing-requires'
unnecessaryRequires = require './../pipes/unnecessary-requires'
output = require './../pipes/output'

module.exports = (streamWithAST, filePath, options) ->
  stream: streamWithAST
  findMissingRequires: ->
    @stream.pipe es.map missingRequires()
    @
  findUnnecessaryRequires: ->
    @stream.pipe es.map unnecessaryRequires()
    @
  output: ->
    @stream.pipe es.map output filePath, options
    @
