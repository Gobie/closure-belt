js = require '../manipulators/javascript'
coffee = require '../manipulators/coffeescript'

module.exports = (ext) ->
  switch ext
    when '.js' then manipulator = js
    when '.coffee' then manipulator = coffee
    else throw new Error "Unsupported extension #{ext}"

  parseToAST: (options) ->
    (data, cb) ->
      cb null, manipulator.parseToAST data, options
  analyzeAST: (options) ->
    (data, cb) ->
      cb null, manipulator.analyzeAST data, options
