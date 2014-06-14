es = require 'event-stream'
missingRequires = require './pipes/missing-requires'
unnecessaryRequires = require './pipes/unnecessary-requires'

module.exports = (streamWithAST) ->
  stream: streamWithAST
  findMissingRequires: ->
    @stream.pipe es.map missingRequires()
    @
  findUnnecessaryRequires: ->
    @stream.pipe es.map unnecessaryRequires()
    @
