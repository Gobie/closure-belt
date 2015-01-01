fs = require 'fs'
through2 = require 'through2'
globStream = require 'glob-stream'
coffee = require 'coffee-script'

process.stdout.setMaxListeners 0

class ClosureBelt
  constructor: () ->
    @_transforms = []

  use: (transform) ->
    @_transforms.push transform
    @

  process: (paths, done) ->
    stream = globStream.create paths
    stream = @_readFile stream
    stream = @_createAST stream
    for transform in @_transforms
      stream = stream.pipe transform
    stream = @_writeFile stream
    stream.on 'finish', ->
      done()
    return

  _readFile: (stream) ->
    stream.pipe through2.obj (chunk, enc, cb) ->
      try
        content = fs.readFileSync chunk.path
      catch err
        return cb err
      console.log '_readFile', chunk.path
      cb null,
        path: chunk.path
        content: content.toString()
    .on 'error', (err) ->
      console.error 'read file', err

  _createAST: (stream) ->
    stream.pipe through2.obj (chunk, enc, cb) ->
      try
        chunk.ast = coffee.nodes chunk.content
      catch err
        return cb err
      console.log '_createAST', chunk.path
      cb null, chunk
    .on 'error', (err) ->
      console.error 'to ast err', err

  _writeFile: (stream) ->
    stream.pipe through2.obj (chunk, enc, cb) ->
      try
        fs.writeFileSync chunk.path, chunk.content
      catch err
        return cb err
      console.log '_writeFile', chunk.path
      cb null, chunk.path
    .on 'error', (err) ->
      console.error 'ast to string err', err

module.exports = ClosureBelt
