closure = require './lib/closure'

console.time 'app'
process.on 'exit', ->
  console.timeEnd 'app'

paths = ['tests/data/**/*.js']
options =
  loc: no
closure.analyzeDirs paths, options