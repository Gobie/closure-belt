vinylFs = require 'vinyl-fs'
through2 = require 'through2'
_ = require 'lodash-node'

class ClosureBelt
  constructor: (options) ->
    @_options = _.defaults options or {},
      log: no
      resolveFileStatus: (chunk) -> yes
    @_transforms = []

  use: (transform, options) ->
    @_transforms.push {transform, options}
    @

  process: (paths, done) ->
    status = {}
    errorHandler = @_createErrorHandler status

    stream = vinylFs.src paths
    stream = stream.pipe @_remember status
    stream = stream.pipe @_transform errorHandler
    stream = stream.pipe @_recall status, errorHandler
    .on 'finish', ->
      done status if _.every status
    stream

  _createErrorHandler: (status) ->
    (msg, filePath) =>
      (err) =>
        status[filePath] = err
        console.warn "error in #{msg}: #{filePath}\n", err if @_options.log

  _remember: (status) ->
    through2.obj (chunk, enc, cb) ->
      status[chunk.path] = undefined
      cb null,
        path: chunk.path
        stream: chunk

  _transform: (errorHandler) ->
    through2.obj (chunk, enc, cb) =>
      for {transform, options}, i in @_transforms
        options = _.defaults path: chunk.path, _.defaults options or {}, @_options
        chunk.stream = chunk.stream.pipe transform options
        chunk.stream.on 'error', errorHandler "transformation ##{i + 1}", chunk.path
      cb null, chunk

  _recall: (status, errorHandler) ->
    through2.obj (chunk, enc, cb) =>
      chunk.stream = chunk.stream.pipe through2.obj (chunk, enc, cb) =>
        status[chunk.path] = @_options.resolveFileStatus chunk
        cb null, chunk
      chunk.stream.on 'error', errorHandler 'resolve file status', chunk.path
      cb null, chunk

module.exports = ClosureBelt
