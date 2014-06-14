require 'coffee-errors'
path = require 'path'
glob = require 'glob'
fs = require 'fs'
es = require 'event-stream'
_ = require 'lodash-node'
fixApostrophes = require './pipes/fix-apostrophes'
manipulatorFactory = require './manipulator-factory'
output = require './pipes/output'
ASTAnalyzer = require './ast-analyzer'

process.stdout.setMaxListeners 0

module.exports =
  analyzeDirs: (dirPaths, options) ->
    for dirPath in dirPaths
      glob dirPath, {}, (err, filePaths) =>
        for filePath in filePaths
          analyzer = @analyzeFile filePath, options
          analyzer.findMissingRequires()
          analyzer.findUnnecessaryRequires()
          analyzer.stream.pipe es.map output filePath, options

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
    ASTAnalyzer stream

  fixApostrophes: (filePath) ->
    stream = @readFile filePath
    stream = stream.pipe es.map fixApostrophes()
    stream
