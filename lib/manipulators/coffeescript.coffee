traverse = require '../utils/traverse'
coffee = require 'coffee-script'

class Manipulator
  parseToAST: (code, options) ->
    coffee.nodes code, options

  analyzeAST: (ast, options) ->
    ast

module.exports = new Manipulator