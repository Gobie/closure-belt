expect = require('chai').expect
es = require 'event-stream'
fs = require 'fs'
closure = require '../lib/index'

describe 'fix apostrophes in goog.(provide|require)', ->
  it 'should fix apostrophes in goog.(require|provide)', (done) ->
    inputFilePath = 'tests/data/test_apostrophes.js'
    outputFilePath = 'tests/data/test_apostrophes_fixed.js'

    stream = closure.fixApostrophes inputFilePath
    stream.pipe es.map (data, cb) ->
      expect(data).to.eql ("" + fs.readFileSync outputFilePath)
      done()
      cb()
