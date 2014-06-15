require 'coffee-errors'
glob = require 'glob'
fixApostrophesCommand = require './commands/fix-apostrophes'
analyzeCommand = require './commands/analyze'
cpdCommand = require './commands/cpd'

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
    analyzeCommand filePath, options

  fixApostrophes: (filePath) ->
    fixApostrophesCommand filePath

  copyPasteDetector: (options = {}) ->
    cpdCommand options
