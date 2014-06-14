_ = require 'lodash-node'
traverse = require '../../utils/traverse'
esprima = require 'esprima'

manipulator =
  parseToAST: (code, options) ->
    options = _.defaults options, tolerant: yes
    esprima.parse code, options

  analyzeAST: (ast, options) ->
    results =
      provides: {}
      requires: {}
      namespaces: {}
    traverse ast, parseNode options, results
    results

getLineAndColumn = (locNode) ->
  line: locNode['loc']['start']['line']
  columnStart: locNode['loc']['start']['column']

parseNode = (options, results) ->
  (key, value, parentNode) ->
    if key is 'callee' and value['type'] is "MemberExpression"
      if value['object']['name'] is 'goog' and value['property']['name'] is 'provide'
        node = parentNode['arguments'][0]
        results['provides'][node['value']] = if options['loc'] then getLineAndColumn node else yes
        return yes

      if value['object']['name'] is 'goog' and value['property']['name'] is 'require'
        node = parentNode['arguments'][0]
        results['requires'][node['value']] = if options['loc'] then getLineAndColumn node else yes
        return yes

    if value?['type']? and value['type'] is 'MemberExpression'
      builder = []
      node = value
      while node['type'] isnt 'Identifier'
        unless node['type'] in ['MemberExpression', 'Identifier']
          traverse node, parseNode options, results
          return yes
        builder.push node['property']['name']
        node = node['object']
      builder.push node['name']

      key = builder.reverse().join '.'
      return yes unless key.match /^(goog|an|este)\./

      results['namespaces'][key] = if options['loc'] then getLineAndColumn node else yes
      yes

module.exports = manipulator