glob = require 'glob'
async = require 'async'
_ = require 'lodash-node'
coffee = require 'coffee-script'
fs = require 'fs'
temporary = require 'temporary'
through2 = require 'through2'
readFile = require './lib/utils/read-file-to-stream'

process.stdout.setMaxListeners 0

class ClosureBelt
  constructor: () ->
    @_transforms = []

  use: (transform) ->
    @_transforms.push transform
    @

  # TODO extract expand paths
  process: (paths, done) ->
    paths = [paths] unless _.isArray paths
    async.waterfall [
      (next) ->
        async.map paths, (path, cb) ->
          glob path, {}, cb
        , next
      (filePaths, next) ->
        next null, _.flatten filePaths
      (filePaths, next) =>
        async.map filePaths, @processFile, next
    ], (err, results) ->
      done? err, results

  processFile: (filePath, done) =>
    stream = readFile filePath
    stream = @_createASTStream stream

    for transform in @_transforms
      stream = stream.pipe transform

    @_writeASTStreamToFile stream, filePath, done
    return

  _createASTStream: (stream) ->
    stream.pipe through2.obj (chunk, enc, cb) ->
      content = chunk.toString()
      try
        ast = coffee.nodes content
      catch err
        return cb err

      cb null, {content, ast}
    .on 'error', (err) ->
      console.log 'to ast err', err

  _writeASTStreamToFile: (stream, filePath, done) ->
    tempFile = new temporary.File()
    tempFilePath = tempFile.path

    stream = stream.pipe through2.obj (chunk, enc, cb) ->
      cb null, chunk.content
    .on 'error', (err) ->
      console.log 'ast to string err', err

    outStream = stream.pipe(fs.createWriteStream tempFilePath)
    .on 'error', (err) ->
      console.log 'out stream err', err

    stream.on 'end', ->
      fs.rename tempFilePath, filePath, (err) ->
        console.log 'rename error', err if err
        done null, filePath
    outStream

module.exports = ClosureBelt
