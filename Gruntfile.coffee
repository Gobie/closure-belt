module.exports = (grunt) ->
  require('time-grunt')(grunt);
  require('load-grunt-tasks')(grunt);

  grunt.initConfig
    mochaTest:
      tests:
        options:
          reporter: 'spec'
          require: 'coffee-script/register'
          clearRequireCache: yes
        src: ['tests/*.coffee']
    coffeelint:
      lib: src: ['lib/**/*.coffee', 'index.coffee']
      server: src: ['server.coffee']
      tests: src: ['tests/*.coffee']
      options:
        max_line_length:
          value: 120
    watch:
      lib:
        files: '<%= coffeelint.lib.src %>'
        tasks: ['coffeelint:lib', 'mochaTest:tests']
      server:
        files: '<%= coffeelint.server.src %>'
        tasks: ['coffeelint:server']
      tests:
        files: '<%= mochaTest.tests.src %>',
        tasks: ['coffeelint:tests', 'mochaTest:tests']

  grunt.registerTask 'default', ['coffeelint', 'mochaTest']
