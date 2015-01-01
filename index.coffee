fs = require 'fs'
through2 = require 'through2'
globStream = require 'glob-stream'
coffee = require 'coffee-script'
_ = require 'lodash-node'

process.stdout.setMaxListeners 0

class ClosureBelt
  constructor: () ->
    @_transforms = []

  use: (transform) ->
    @_transforms.push transform
    @

  process: (paths, done) ->
    filesToProcess = {}

    errorHandler = (msg, filePath) ->
      (err) ->
        filesToProcess[filePath] = err

    stream = globStream.create paths
    stream = stream.pipe through2.obj (chunk, enc, cb) ->
      filesToProcess[chunk.path] = no
      cb null, chunk

    stream = @_readFile stream, errorHandler
    stream = @_createAST stream, errorHandler
    stream = @_transform stream, errorHandler
    stream = @_writeFile stream, errorHandler

    stream = stream.pipe through2.obj (chunk, enc, cb) ->
      chunk.stream = chunk.stream.pipe through2.obj (chunk, enc, cb) ->
        filesToProcess[chunk.path] = yes
        cb null, chunk
      chunk.stream.on 'error', errorHandler 'merge'
      chunk.stream.on 'finish', ->
        done null, filesToProcess if _.every filesToProcess
      cb()

    stream.on 'finish', ->
      done null, filesToProcess if _.isEmpty(filesToProcess)
    return

  _readFile: (stream, errorHandler) ->
    stream.pipe through2.obj (chunk, enc, cb) ->
      stream = fs.createReadStream chunk.path
      stream.on 'error', errorHandler 'read'

      filePath = chunk.path
      stream = stream.pipe through2.obj (chunk, enc, cb) ->
        @_content ?= ''
        @_content += chunk.toString()
        cb()
      , (cb) ->
        @push
          path: filePath
          content: @_content
        cb()
      stream.on 'error', errorHandler 'concat', chunk.path

      cb null,
        path: chunk.path
        stream: stream

  _createAST: (stream, errorHandler) ->
    stream.pipe through2.obj (chunk, enc, cb) ->
      chunk.stream = chunk.stream.pipe through2.obj (chunk, enc, cb) ->
        try
          chunk.ast = coffee.nodes chunk.content
        catch err
          return cb err
        cb null, chunk
      chunk.stream.on 'error', errorHandler 'ast', chunk.path

      cb null, chunk

  _transform: (stream, errorHandler) ->
    stream.pipe through2.obj (chunk, enc, cb) =>
      for transform, i in @_transforms
        chunk.stream = chunk.stream.pipe transform
        chunk.stream.on 'error', errorHandler "transform #{i}", chunk.path

      cb null, chunk

  _writeFile: (stream, errorHandler) ->
    stream.pipe through2.obj (chunk, enc, cb) ->
      chunk.stream = chunk.stream.pipe through2.obj (chunk, enc, cb) ->
        try
          fs.writeFileSync chunk.path, chunk.content
        catch err
          return cb err
        cb null, chunk
      chunk.stream.on 'error', errorHandler 'write', chunk.path

      cb null, chunk

module.exports = ClosureBelt
