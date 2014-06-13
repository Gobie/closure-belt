clc = require 'cli-color'
_ = require 'lodash-node'
info = clc.greenBright

module.exports = (filePath, options) ->
  (data, cb) ->
    hasMissing = data['missing']? and not _.isEmpty data['missing']
    hasUnnecessary = data['unnecessary']? and not _.isEmpty data['unnecessary']

    if hasMissing or hasUnnecessary
      out = []
      out.push "#{info('Requires in ' + filePath)}\n"

    if hasMissing
      for namespace, coords of data['missing']
        out.push "  missing for #{namespace}"
        out.push " at line: #{coords['line']} and column: #{coords['columnStart']}" if options['loc']
        out.push "\n"

    if hasUnnecessary
      for namespace, coords of data['unnecessary']
        out.push "  unnecessary #{namespace}"
        out.push " at line: #{coords['line']} and column: #{coords['columnStart']}" if options['loc']
        out.push "\n"

    if hasMissing or hasUnnecessary
      console.log out.join ''

    cb null, data