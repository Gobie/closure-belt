through2 = require 'through2'
_ = require 'lodash-node'
nodes = require 'coffee-script/lib/coffee-script/nodes'

getLineAndColumn = (locNode) ->
  line: locNode.locationData.first_line
  column: locNode.locationData.first_column

parseNode = (options, results) ->

  apostrophesRegex = /["']/g
  (node) ->
    if node instanceof nodes.Call and node.variable instanceof nodes.Value

      # goog.provide '...'
      if node.variable.base.value is 'goog' and node.variable.properties[0].name.value is 'provide'
        node = node.args[0].base
        namespace = node.value.replace apostrophesRegex, ''
        results.provides[namespace] = if options.loc then getLineAndColumn node else yes
        return no

      # goog.require '...'
      if node.variable.base.value is 'goog' and node.variable.properties[0].name.value is 'require'
        node = node.args[0].base
        namespace = node.value.replace apostrophesRegex, ''
        results.requires[namespace] = if options.loc then getLineAndColumn node else yes
        return no

    # goog.(...)
    if node instanceof nodes.Value and node.base instanceof nodes.Literal
      parts = []
      parts.push node.base.value
      for property in node.properties
        return yes unless property.name?.value? and property.name.asKey is yes
        parts.push property.name.value
      key = parts.join '.'
      return yes unless key.match options.validUseRegex

      results.uses[key] = if options.loc then getLineAndColumn node.base else yes

    yes

module.exports = (options) ->
  options = _.defaults options or {},
    loc: no
    validUseRegex: /^goog\./

  through2.obj (chunk, enc, cb) ->
    return cb new Error 'no ast in stream' unless chunk.ast

    results =
      provides: {}
      requires: {}
      uses: {}
    chunk.ast.traverseChildren yes, parseNode options, results
    chunk.dependencies = results
    cb null, chunk