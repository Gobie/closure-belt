fs = require 'fs'
path = require 'path'
expect = require('chai').expect
ClosureBelt = require '../index'
readFileStream = require '../lib/streams/read-file'
writeFileStream = require '../lib/streams/write-file'
createASTStream = require '../lib/streams/coffee-create-ast'
closureDependenciesStream = require '../lib/streams/coffee-closure-dependencies'
redundantRequiresStream = require '../lib/streams/redundant-requires'

describe 'ClosureBelt', ->

  describe 'process', ->

    it 'should do nothing with non-existing file', (done) ->
      testFilepath = 'unknown.coffee'
      belt = new ClosureBelt()
      belt.process testFilepath, (results) ->
        expect(results).to.eql {}
        done()

    it 'should process valid coffeescript file and save without change', (done) ->
      testFilepath = 'tests/data/valid.coffee'
      testFileContent = fs.readFileSync(testFilepath).toString()
      belt = new ClosureBelt()
      belt.use readFileStream
      belt.use createASTStream
      belt.use writeFileStream
      belt.process testFilepath, (results) ->
        newTestFileContent = fs.readFileSync(testFilepath).toString()
        expect(newTestFileContent).to.eql testFileContent
        expect(results[path.resolve __dirname, 'data/valid.coffee']).to.be.yes
        done()

    it 'should process invalid coffeescript files and return error in results', (done) ->
      testFilepath = 'tests/data/invalid.coffee'
      belt = new ClosureBelt()
      belt.use readFileStream
      belt.use createASTStream
      belt.process testFilepath, (results) ->
        expect(results[path.resolve __dirname, 'data/invalid.coffee']).to.be.error
        done()

    it 'should process invalid and valid coffeescript files and return error in results', (done) ->
      testFilepath = ['tests/data/invalid.coffee', 'tests/data/valid.coffee']
      belt = new ClosureBelt()
      belt.use readFileStream
      belt.use createASTStream
      belt.process testFilepath, (results) ->
        expect(results[path.resolve __dirname, 'data/invalid.coffee']).to.be.error
        expect(results[path.resolve __dirname, 'data/valid.coffee']).to.be.yes
        done()

    it 'should process file and return gathered information', (done) ->
      testFilepath = ['tests/data/valid.coffee']
      belt = new ClosureBelt
        resolveFileStatus: (chunk) -> chunk.ast
      belt.use readFileStream
      belt.use createASTStream
      belt.process testFilepath, (results) ->
        expect(results[path.resolve __dirname, 'data/valid.coffee']).to.be.object
        done()

    it 'should list dependencies', (done) ->
      testFilepath = ['tests/data/valid.coffee']
      belt = new ClosureBelt
        resolveFileStatus: (chunk) -> chunk.dependencies
      belt.use readFileStream
      belt.use createASTStream
      belt.use closureDependenciesStream
      belt.process testFilepath, (results) ->
        expect(results[path.resolve __dirname, 'data/valid.coffee']).to.eql
          'uses':
            'goog.a11y.aria.Announcer': yes
            'goog.a11y.aria.Announcer.base': yes
            'goog.a11y.aria.Announcer.prototype.disposeInternal': yes
            'goog.a11y.aria.Announcer.prototype.getLiveRegion_': yes
            'goog.a11y.aria.Announcer.prototype.say': yes
            'goog.a11y.aria.LivePriority.POLITE': yes
            'goog.a11y.aria.State.ATOMIC': yes
            'goog.a11y.aria.State.HIDDEN': yes
            'goog.a11y.aria.State.LIVE': yes
            'goog.a11y.aria.removeState': yes
            'goog.a11y.aria.setState': yes
            'goog.Disposable': yes
            'goog.dom.getDomHelper': yes
            'goog.dom.setTextContent': yes
            'goog.inherits': yes
            'goog.object.forEach': yes
          'provides':
            'goog.a11y.aria.Announcer': yes
          'requires':
            'goog.Disposable': yes
            'goog.a11y.aria': yes
            'goog.a11y.aria.LivePriority': yes
            'goog.a11y.aria.State': yes
            'goog.dom': yes
            'goog.object': yes
        done()

    it 'should list redundant requires', (done) ->
      testFilepath = ['tests/data/redundant-requires.coffee']
      belt = new ClosureBelt
        resolveFileStatus: (chunk) ->
          dependencies: chunk.dependencies
          redundant_requires: chunk.redundant_requires
      belt.use readFileStream
      belt.use createASTStream
      belt.use closureDependenciesStream
      belt.use redundantRequiresStream
      belt.process testFilepath, (results) ->
        expect(results[path.resolve __dirname, 'data/redundant-requires.coffee']).to.eql
          dependencies:
            provides:
              'goog.tweak.EntriesPanel': yes
              'goog.tweak.TweakUi': yes
            requires:
              'goog.array': yes
              'goog.asserts': yes
              'goog.dom.DomHelper': yes
              'goog.object': yes
              'goog.style': yes
              'goog.tweak': yes
              'goog.ui.Zippy': yes
              'goog.userAgent': yes
            uses:
              'goog.tweak.TweakUi': yes
              'goog.tweak.TweakUi.ROOT_PANEL_CLASS_': yes
              'goog.tweak.TweakUi.ENTRY_CSS_CLASS_': yes
              'goog.tweak.TweakUi.ENTRY_CSS_CLASSES_': yes
              'goog.tweak.TweakUi.ENTRY_GROUP_CSS_CLASSES_': yes
              'goog.tweak.TweakUi.STYLE_SHEET_INSTALLED_MARKER_': yes
              'goog.tweak.TweakUi.CSS_STYLES_': yes
              'goog.tweak.TweakUi.create': yes
              'goog.tweak.TweakUi.createCollapsible': yes
              'goog.tweak.TweakUi.entryCompare_': yes
              'goog.tweak.TweakUi.isGroupEntry_': yes
              'goog.tweak.TweakUi.extractBooleanGroupEntries_': yes
              'goog.tweak.TweakUi.extractNamespace_': yes
              'goog.tweak.TweakUi.getNamespacedLabel_': yes
              'goog.tweak.TweakUi.prototype.getRootElement': yes
              'goog.tweak.TweakUi.prototype.restartWithAppliedTweaks_': yes
              'goog.tweak.TweakUi.prototype.installStyles_': yes
              'goog.tweak.TweakUi.prototype.render': yes
              'goog.tweak.TweakUi.prototype.onNewRegisteredEntry_': yes
              'goog.tweak.TweakUi.prototype.insertEntry_': yes
              'goog.tweak.EntriesPanel': yes
              'goog.tweak.EntriesPanel.prototype.getRootElement': yes
              'goog.tweak.EntriesPanel.prototype.render': yes
              'goog.tweak.EntriesPanel.prototype.insertEntry': yes
              'goog.tweak.EntriesPanel.prototype.createEntryElem_': yes
              'goog.tweak.EntriesPanel.prototype.onHelpClick_': yes
              'goog.tweak.EntriesPanel.prototype.showDescription_': yes
              'goog.tweak.EntriesPanel.prototype.createHelpElem_': yes
              'goog.tweak.EntriesPanel.prototype.toggleAllDescriptions': yes
              'goog.tweak.EntriesPanel.prototype.createComboBoxDom_': yes
              'goog.tweak.EntriesPanel.prototype.createBooleanSettingDom_': yes
              'goog.tweak.EntriesPanel.prototype.createSubPanelDom_': yes
              'goog.tweak.EntriesPanel.prototype.createTextBoxDom_': yes
              'goog.tweak.EntriesPanel.prototype.createButtonActionDom_': yes
              'goog.tweak.EntriesPanel.prototype.createTweakEntryDom_': yes
              'goog.tweak.NamespaceEntry_': yes
              'goog.tweak.NamespaceEntry_.ID_PREFIX': yes
              'goog.tweak.NumericSetting': yes
              'goog.tweak.StringSetting': yes
              'goog.tweak.TweakUi.prototype.restartWithAppliedTweaks_': yes
              'goog.tweak.getRegistry': yes
              'goog.ui.Zippy': yes
              'goog.userAgent.IE': yes
              'goog.userAgent.MOBILE': yes
              'goog.array.binarySearch': yes
              'goog.array.defaultCompare': yes
              'goog.array.insertAt': yes
              'goog.asserts.assert': yes
              'goog.asserts.assertInstanceof': yes
              'goog.bind': yes
              'goog.dom.getDomHelper': yes
              'goog.dom.setTextContent': yes
              'goog.getCssName': yes
              'goog.inherits': yes
              'goog.object.getValues': yes
              'goog.style.installStyles': yes
              'goog.style.setElementShown': yes
              'goog.tweak.BaseEntry': yes
              'goog.tweak.BaseEntry.call': yes
              'goog.tweak.BooleanGroup': yes
              'goog.tweak.BooleanInGroupSetting': yes
              'goog.tweak.BooleanSetting': yes
              'goog.tweak.ButtonAction': yes
          redundant_requires:
            'goog.dom.DomHelper': yes
        done()
