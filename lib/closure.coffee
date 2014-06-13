require 'coffee-errors'
path = require 'path'
glob = require 'glob'
fs = require 'fs'
es = require 'event-stream'
_ = require 'lodash-node'
fixApostrophes = require './pipes/fix-apostrophes'
manipulatorFactory = require './pipes/manipulator'
missingRequires = require './pipes/missing-requires'
output = require './pipes/output'
unnecessaryRequires = require './pipes/unnecessary-requires'

process.stdout.setMaxListeners 0

module.exports =
  analyzeDirs: (dirPaths, options) ->
    for dirPath in dirPaths
      glob dirPath, {}, (err, filePaths) =>
        for filePath in filePaths
          stream = @analyzeFile filePath, options
          stream = @findMissingRequires stream
          stream = @findUnnecessaryRequires stream
          stream.pipe es.map output filePath, options

  readFile: (filePath) ->
    stream = fs.createReadStream filePath
    stream = stream.pipe es.wait()
    stream

  analyzeFile: (filePath, options = {}) ->
    options = _.defaults options, loc: no
    manipulator = manipulatorFactory path.extname filePath
    stream = @readFile filePath
    stream = stream.pipe es.map manipulator.parseToAST options
    stream = stream.pipe es.map manipulator.analyzeAST options
    stream

  findMissingRequires: (streamWithAST) ->
    stream = streamWithAST.pipe es.map missingRequires()
    stream

  findUnnecessaryRequires: (streamWithAST) ->
    stream = streamWithAST.pipe es.map unnecessaryRequires()
    stream

  fixApostrophes: (filePath) ->
    stream = @readFile filePath
    stream = stream.pipe es.map fixApostrophes()
    stream
