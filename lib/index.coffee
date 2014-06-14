require 'coffee-errors'
glob = require 'glob'
es = require 'event-stream'
_ = require 'lodash-node'
fixApostrophesCommand = require './commands/fix-apostrophes'
analyzeCommand = require './commands/analyze'

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
    fixApostrophesCommand filePath
