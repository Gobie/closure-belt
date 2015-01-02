_ = require 'lodash-node'

module.exports = (defaultOptions, cb) ->
  (streamOptions) ->
    (globalOptions, filePath) ->
      options = _.defaults streamOptions or {},
        _.defaults globalOptions or {},
          defaultOptions

      cb options, filePath