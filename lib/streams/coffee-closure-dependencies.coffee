through2 = require 'through2'
_ = require 'lodash-node'

getLineAndColumn = (locNode) ->
  line: locNode['locationData']['first_line']
  column: locNode['locationData']['first_column']

parseNode = (options, results) ->
  apostrophesRegex = /["']/g
  (node) ->
    if node.variable?.base? and node.variable.properties? and node.args?
      if node.variable.base.value is 'goog' and
      node.variable.properties[0].name.value is 'provide'
        node = node.args[0].base
        namespace = node.value.replace apostrophesRegex, ''
        results.provides[namespace] = if options.loc then getLineAndColumn node else yes
        return yes

      if node.variable.base.value is 'goog' and
      node.variable.properties[0].name.value is 'require'
        node = node.args[0].base
        namespace = node.value.replace apostrophesRegex, ''
        results.requires[namespace] = if options.loc then getLineAndColumn node else yes
        return yes

    if node.base?.value? and node.properties?
      parts = []
      parts.push node.base.value
      for property in node.properties
        return yes unless property.name?.value?
        parts.push property.name.value
      key = parts.join '.'
      return yes unless key.match options.validUseRegex

      results.uses[key] = if options.loc then getLineAndColumn node.base else yes
      yes

module.exports = (streamOptions) ->
  (globalOptions, filePath) ->
    options = _.defaults streamOptions or {},
      _.defaults globalOptions or {},
        loc: no
        validUseRegex: /^goog\./

    through2.obj (chunk, enc, cb) ->
      results =
        provides: {}
        requires: {}
        uses: {}
      chunk.ast.traverseChildren no, parseNode options, results
      chunk.dependencies = results
      cb null, chunk