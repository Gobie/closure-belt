_ = require 'lodash-node'

module.exports = (defaultOptions, cb) ->
  (streamOptions) ->
    (filePath) ->
      options = _.defaults streamOptions or {}, defaultOptions

      cb options, filePath