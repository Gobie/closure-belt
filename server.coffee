closure = require './lib/index'

console.time 'app'
process.on 'exit', ->
  console.timeEnd 'app'

paths = ['tests/data/**/*.js']
options =
  loc: no
closure.analyzeDirs paths, options
#closure.copyPasteDetector path: './tests/data/'