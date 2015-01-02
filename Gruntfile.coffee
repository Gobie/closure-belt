module.exports = (grunt) ->
  require('time-grunt')(grunt);
  require('load-grunt-tasks')(grunt);

  files =
    src: ['lib/**/*.coffee', 'index.coffee']
    tests: ['tests/**/*.spec.coffee']

  grunt.initConfig
    mochaTest:
      tests:
        options:
          reporter: 'spec'
          require: 'coffee-script/register'
          clearRequireCache: yes
        src: files.tests
    coffeelint:
      lib: src: files.src
      tests: src: files.tests
      options:
        max_line_length:
          value: 120
    watch:
      lib:
        files: files.src
        tasks: ['coffeelint:lib', 'mochaTest:tests']
      tests:
        files: files.tests,
        tasks: ['coffeelint:tests', 'mochaTest:tests']

  grunt.registerTask 'default', ['coffeelint', 'mochaTest']
