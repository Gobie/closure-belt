traverse = require '../../utils/traverse'
coffee = require 'coffee-script'

manipulator =
  parseToAST: (code, options) ->
    coffee.nodes code, options

  analyzeAST: (ast, options) ->
    results =
      provides: {}
      requires: {}
      namespaces: {}
    traverse ast, parseNode options, results
    results

getLineAndColumn = (locNode) ->
  line: locNode['locationData']['first_line']
  columnStart: locNode['locationData']['first_column']

parseNode = (options, results) ->
  apostrophesRegex = /["']/g
  (key, value, parentNode) ->
    if value?['variable']?['base']? and value['variable']['properties']? and value['args']?
      if value['variable']['base']['value'] is 'goog' and
      value['variable']['properties'][0]['name']['value'] is 'provide'
        node = value['args'][0]['base']
        namespace = node['value'].replace apostrophesRegex, ''
        results['provides'][namespace] = if options['loc'] then getLineAndColumn node else yes
        return yes

      if value['variable']['base']['value'] is 'goog' and
      value['variable']['properties'][0]['name']['value'] is 'require'
        node = value['args'][0]['base']
        namespace = node['value'].replace apostrophesRegex, ''
        results['requires'][namespace] = if options['loc'] then getLineAndColumn node else yes
        return yes

    if value?['base']?['value']? and value['properties']?
      builder = []
      builder.push value['base']['value']
      for property in value['properties']
        return yes unless property['name']?['value']?
        builder.push property['name']['value']
      key = builder.join '.'
      return yes unless key.match /^(goog|an|este)\./

      results['namespaces'][key] = if options['loc'] then getLineAndColumn value['base'] else yes
      yes

module.exports = manipulator