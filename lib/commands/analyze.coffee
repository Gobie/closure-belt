path = require 'path'
es = require 'event-stream'
_ = require 'lodash-node'
manipulatorFactory = require './../analyzer/manipulators/factory'
analyzer = require './../analyzer/analyzer'
readFile = require './../utils/read-file-to-stream'

module.exports = (filePath, options) ->
  options = _.defaults options, loc: no
  manipulator = manipulatorFactory path.extname filePath
  stream = readFile filePath
  stream = stream.pipe es.map manipulator.parseToAST options
  stream = stream.pipe es.map manipulator.analyzeAST options
  analyzer stream, filePath, options
