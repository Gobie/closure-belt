fs = require 'fs'
through2 = require 'through2'
globStream = require 'glob-stream'
_ = require 'lodash-node'

class ClosureBelt
  constructor: (options) ->
    @_options = _.defaults options || {},
      log: no
    @_transforms = []

  use: (transform) ->
    @_transforms.push transform
    @

  process: (paths, done) ->
    filesStatus = {}
    stream = globStream.create paths
    stream = @_remember stream, filesStatus
    stream = @_readFile stream, @_createErrorHandler filesStatus
    stream = @_transform stream, @_createErrorHandler filesStatus
    stream = @_recall stream, filesStatus, done
    return

  _createErrorHandler: (filesStatus) ->
    (msg, filePath) =>
      (err) =>
        filesStatus[filePath] = err
        console.warn "error in #{msg}: #{filePath}\n", err if @_options.log

  _remember: (stream, filesStatus) ->
    stream.pipe through2.obj (chunk, enc, cb) ->
      filesStatus[chunk.path] = no
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

  _recall: (stream, filesStatus, done) ->
    stream.pipe through2.obj (chunk, enc, cb) ->
      chunk.stream = chunk.stream.pipe through2.obj (chunk, enc, cb) ->
        filesStatus[chunk.path] = yes
        cb null, chunk
      chunk.stream.on 'finish', ->
        done filesStatus if _.every filesStatus
      cb null, chunk
    .on 'finish', ->
      done filesStatus if _.isEmpty filesStatus

module.exports = ClosureBelt
