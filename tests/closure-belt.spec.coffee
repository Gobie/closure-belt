expect = require('chai').expect
sinon = require 'sinon'
fs = require 'fs'
ClosureBelt = require '../index'

describe 'ClosureBelt', ->

  describe 'process', ->

    it 'should do nothing with non-existing file', (done) ->
      testFilepath = 'unknown.coffee'
      belt = new ClosureBelt()
      belt.process testFilepath, (err, results) ->
        expect(err).to.be.null
        expect(results).to.eql {}
        done()

    it 'should process valid coffeescript file without change', (done) ->
      testFilepath = 'tests/data/valid.coffee'
      testFileContent = fs.readFileSync(testFilepath).toString()
      belt = new ClosureBelt()
      belt.process testFilepath, (err, results) ->
        newTestFileContent = fs.readFileSync(testFilepath).toString()
        expect(newTestFileContent).to.eql testFileContent
        expect(err).to.be.null
        expect(results).to.eql
          '/Users/michalbrasna/Projects/closure-belt/tests/data/valid.coffee': yes
        done()

    it 'should throw error with invalid coffeescript file', (done) ->
      testFilepath = ['tests/data/invalid.coffee', 'tests/data/valid.coffee']
      belt = new ClosureBelt()
      belt.process testFilepath, (err, results) ->
        expect(err).to.be.null
        expect(results['/Users/michalbrasna/Projects/closure-belt/tests/data/invalid.coffee']).to.be.error
        expect(results['/Users/michalbrasna/Projects/closure-belt/tests/data/valid.coffee']).to.be.true
        done()
