javascript = require './manipulators/javascript'
coffeescript = require './manipulators/coffeescript'

module.exports = (ext) ->
  switch ext
    when '.js' then manipulator = javascript
    when '.coffee' then manipulator = coffeescript
    else throw new Error "Unsupported extension #{ext}"

  parseToAST: (options) ->
    (data, cb) ->
      cb null, manipulator.parseToAST data, options
  analyzeAST: (options) ->
    (data, cb) ->
      cb null, manipulator.analyzeAST data, options
