fs = require 'fs'
path = require 'path'
expect = require('chai').expect
ClosureBelt = require '../index'
readFileStream = require '../lib/streams/read-file'
writeFileStream = require '../lib/streams/write-file'
createASTStream = require '../lib/streams/coffee-create-ast'
closureDependenciesStream = require '../lib/streams/coffee-closure-dependencies'

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
      belt.use readFileStream()
      belt.use createASTStream()
      belt.use writeFileStream()
      belt.process testFilepath, (results) ->
        newTestFileContent = fs.readFileSync(testFilepath).toString()
        expect(newTestFileContent).to.eql testFileContent
        expect(results[path.resolve __dirname, 'data/valid.coffee']).to.be.true
        done()

    it 'should process invalid coffeescript file and return error in results', (done) ->
      testFilepath = ['tests/data/invalid.coffee', 'tests/data/valid.coffee']
      belt = new ClosureBelt()
      belt.use readFileStream()
      belt.use createASTStream()
      belt.process testFilepath, (results) ->
        expect(results[path.resolve __dirname, 'data/invalid.coffee']).to.be.error
        expect(results[path.resolve __dirname, 'data/valid.coffee']).to.be.true
        done()

    it 'should process file and return gathered information', (done) ->
      testFilepath = ['tests/data/valid.coffee']
      belt = new ClosureBelt
        resolveFileStatus: (chunk) -> chunk.ast
      belt.use readFileStream()
      belt.use createASTStream()
      belt.process testFilepath, (results) ->
        expect(results[path.resolve __dirname, 'data/valid.coffee']).to.be.object
        done()

    it 'should list dependencies', (done) ->
      testFilepath = ['tests/data/valid.coffee']
      belt = new ClosureBelt
        resolveFileStatus: (chunk) -> chunk.dependencies
      belt.use readFileStream()
      belt.use createASTStream()
      belt.use closureDependenciesStream()
      belt.process testFilepath, (results) ->
        expect(results[path.resolve __dirname, 'data/valid.coffee']).to.eql
          'uses':
            'goog.Disposable': yes
            'goog.a11y.aria.Announcer': yes
            'goog.a11y.aria.Announcer.prototype.disposeInternal': yes
            'goog.a11y.aria.Announcer.prototype.getLiveRegion_': yes
            'goog.a11y.aria.Announcer.prototype.say': yes
            'goog.inherits': yes
            'goog.provide': yes
            'goog.require': yes
          'provides':
            'goog.a11y.aria.Announcer': yes
          'requires':
            'goog.Disposable': yes
            'goog.a11y.aria': yes
            'goog.a11y.aria.LivePriority': yes
            'goog.a11y.aria.State': yes
            'goog.dom': yes
            'goog.object': yes
        done()