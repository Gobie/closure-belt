fs = require 'fs'
through2 = require 'through2'
globStream = require 'glob-stream'
_ = require 'lodash-node'

class ClosureBelt
  constructor: (options) ->
    @_options = _.defaults options || {},
      log: no
      resolveFileStatus: (chunk) -> yes
    @_transforms = []

  use: (transform) ->
    @_transforms.push transform
    @

  process: (paths, done) ->
    status = {}
    stream = globStream.create paths
    stream = @_remember stream, status
    stream = @_readFile stream, @_createErrorHandler status
    stream = @_transform stream, @_createErrorHandler status
    stream = @_recall stream, status, done
    return

  _createErrorHandler: (status) ->
    (msg, filePath) =>
      (err) =>
        status[filePath] = err
        console.warn "error in #{msg}: #{filePath}\n", err if @_options.log

  _remember: (stream, status) ->
    stream.pipe through2.obj (chunk, enc, cb) ->
      status[chunk.path] = undefined
      cb null, chunk

  _readFile: (stream, errorHandler) ->
    stream.pipe through2.obj (chunk, enc, cb) ->
      stream = fs.createReadStream chunk.path
      stream.on 'error', errorHandler 'read', chunk.path
      cb null,
        path: chunk.path
        stream: stream

  _transform: (stream, errorHandler) ->
    stream.pipe through2.obj (chunk, enc, cb) =>
      for transform, i in @_transforms
        chunk.stream = chunk.stream.pipe transform chunk.path
        chunk.stream.on 'error', errorHandler "transformation ##{i + 1}", chunk.path
      cb null, chunk

  _recall: (stream, status, done) ->
    stream.pipe through2.obj (chunk, enc, cb) =>
      chunk.stream = chunk.stream.pipe through2.obj (chunk, enc, cb) =>
        status[chunk.path] = @_options.resolveFileStatus chunk
        cb null, chunk
      chunk.stream.on 'finish', ->
        done status if _.every status
      cb null, chunk
    .on 'finish', ->
      done status if _.isEmpty status

module.exports = ClosureBelt
