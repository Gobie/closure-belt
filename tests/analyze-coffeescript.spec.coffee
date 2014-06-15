expect = require('chai').expect
es = require 'event-stream'
closure = require '../lib/index'

describe 'analyze - coffeescript', ->
  it 'should analyze file', (done) ->
    filePath = 'tests/data/test_analyze.coffee'
    expectation =
      "provides":
        "goog.a11y.aria.Announcer": yes
      "requires":
        "goog.Disposable": yes
        "goog.a11y.aria": yes
        "goog.a11y.aria.LivePriority": yes
        "goog.a11y.aria.State": yes
        "goog.dom": yes
        "goog.object": yes
      "namespaces":
        "goog.a11y.aria.Announcer": yes
        "goog.a11y.aria.Announcer.base": yes
        "goog.dom.getDomHelper": yes
        "goog.inherits": yes
        "goog.Disposable": yes
        "goog.a11y.aria.Announcer.prototype.disposeInternal": yes
        "goog.object.forEach": yes
        "goog.a11y.aria.Announcer.prototype.say": yes
        "goog.dom.setTextContent": yes
        "goog.a11y.aria.LivePriority.POLITE": yes
        "goog.a11y.aria.Announcer.prototype.getLiveRegion_": yes
        "goog.a11y.aria.removeState": yes
        "goog.a11y.aria.State.HIDDEN": yes
        "goog.a11y.aria.setState": yes
        "goog.a11y.aria.State.LIVE": yes
        "goog.a11y.aria.State.ATOMIC": yes

    analyzer = closure.analyzeFile filePath
    analyzer.stream.pipe es.map (data, cb) ->
      expect(data).to.eql expectation
      done()
      cb()
