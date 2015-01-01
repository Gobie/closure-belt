expect = require('chai').expect
sinon = require 'sinon'
fs = require 'fs'
ClosureBelt = require '../index'

describe 'ClosureBelt', ->

  it 'it should expand paths', (done) ->
    belt = new ClosureBelt()
    belt.processFile = sinon.stub().yields null, 'processed'
    belt.process ['server.coffee'], (err, results) ->
      expect(results.length).to.eql 1
      expect(err).to.be.undefined
      done()

  it 'it should parse and compile file without change', (done) ->
    testFilepath = 'tests/data/test_analyze.coffee'
    testFileContent = fs.readFileSync(testFilepath).toString()

    belt = new ClosureBelt()
    belt.processFile testFilepath, (err, results) ->
      newTestFileContent = fs.readFileSync(testFilepath).toString()
      expect(newTestFileContent).to.eql testFileContent
      expect(err).to.be.null
      done()
