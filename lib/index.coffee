require 'coffee-errors'
glob = require 'glob'
es = require 'event-stream'
_ = require 'lodash-node'
fixApostrophes = require './pipes/fix-apostrophes'
analyzeCommand = require './commands/analyze'
readFile = require './utils/read-file-to-stream'

process.stdout.setMaxListeners 0

module.exports =
  analyzeDirs: (dirPaths, options) ->
    for dirPath in dirPaths
      glob dirPath, {}, (err, filePaths) =>
        for filePath in filePaths
          analyzer = @analyzeFile filePath, options
          analyzer.findMissingRequires()
          analyzer.findUnnecessaryRequires()
          analyzer.output()

  analyzeFile: (filePath, options = {}) ->
    options = _.defaults options, loc: no
    analyzeCommand filePath, options

  fixApostrophes: (filePath) ->
    stream = readFile filePath
    stream = stream.pipe es.map fixApostrophes()
    stream
