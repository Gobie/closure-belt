fs = require 'fs'
path = require 'path'
expect = require('chai').expect
ClosureBelt = require '../index'
readFileStream = require '../lib/streams/read-file'
writeFileStream = require '../lib/streams/write-file'
createASTStream = require '../lib/streams/coffee-create-ast'

describe 'ClosureBelt', ->

  describe 'process', ->

    it 'should do nothing with non-existing file', (done) ->
      testFilepath = 'unknown.coffee'
      belt = new ClosureBelt()
      belt.process testFilepath, (results) ->
        expect(results).to.eql {}
        done()

    it 'should process valid coffeescript file without change', (done) ->
      testFilepath = 'tests/data/valid.coffee'
      testFileContent = fs.readFileSync(testFilepath).toString()
      belt = new ClosureBelt()
      belt.use readFileStream
      belt.use createASTStream
      belt.use writeFileStream
      belt.process testFilepath, (results) ->
        newTestFileContent = fs.readFileSync(testFilepath).toString()
        expect(newTestFileContent).to.eql testFileContent
        expect(results[path.resolve __dirname, 'data/valid.coffee']).to.be.true
        done()

    it 'should process invalid coffeescript file and return error in results', (done) ->
      testFilepath = ['tests/data/invalid.coffee', 'tests/data/valid.coffee']
      belt = new ClosureBelt()
      belt.use readFileStream
      belt.use createASTStream
      belt.use writeFileStream
      belt.process testFilepath, (results) ->
        expect(results[path.resolve __dirname, 'data/invalid.coffee']).to.be.error
        expect(results[path.resolve __dirname, 'data/valid.coffee']).to.be.true
        done()
