through2 = require 'through2'

module.exports = (options) ->
  through2.obj (chunk, enc, cb) ->
    return cb new Error 'no dependencies in stream' unless chunk.dependencies

    chunk.redundant_requires = {}
    for namespace, value of chunk.dependencies.requires
      found = no
      for use of chunk.dependencies.uses when 0 is use.indexOf namespace
        found = yes
        break
      chunk.redundant_requires[namespace] = value unless found

    cb null, chunk
