expect = require('chai').expect
es = require 'event-stream'
fs = require 'fs'
closure = require '../lib/closure'

describe 'closure tests', ->
  it 'should fix apostrophes in goog.(require|provide)', (done) ->
    inputFilePath = 'tests/data/test_apostrophes.js'
    outputFilePath = 'tests/data/test_apostrophes_fixed.js'

    stream = closure.fixApostrophes inputFilePath
    stream.pipe es.map (data, cb) ->
      expect(data).to.eql ("" + fs.readFileSync outputFilePath)
      done()
      cb()

  it 'should find missing requires', (done) ->
    filePath = 'tests/data/test_tweakui.js'
    expectation =
      "missing":
        "goog.dom.getDomHelper": yes
        "goog.dom.setTextContent": yes
      "namespaces":
        "goog.array.binarySearch": yes
        "goog.array.defaultCompare": yes
        "goog.array.insertAt": yes
        "goog.asserts.assert": yes
        "goog.asserts.assertInstanceof": yes
        "goog.bind": yes
        "goog.dom.getDomHelper": yes
        "goog.dom.setTextContent": yes
        "goog.getCssName": yes
        "goog.inherits": yes
        "goog.object.getValues": yes
        "goog.style.installStyles": yes
        "goog.style.setElementShown": yes
        "goog.tweak.BaseEntry": yes
        "goog.tweak.BaseEntry.call": yes
        "goog.tweak.BooleanGroup": yes
        "goog.tweak.BooleanInGroupSetting": yes
        "goog.tweak.BooleanSetting": yes
        "goog.tweak.ButtonAction": yes
        "goog.tweak.EntriesPanel": yes
        "goog.tweak.EntriesPanel.prototype.createBooleanSettingDom_": yes
        "goog.tweak.EntriesPanel.prototype.createButtonActionDom_": yes
        "goog.tweak.EntriesPanel.prototype.createComboBoxDom_": yes
        "goog.tweak.EntriesPanel.prototype.createEntryElem_": yes
        "goog.tweak.EntriesPanel.prototype.createHelpElem_": yes
        "goog.tweak.EntriesPanel.prototype.createSubPanelDom_": yes
        "goog.tweak.EntriesPanel.prototype.createTextBoxDom_": yes
        "goog.tweak.EntriesPanel.prototype.createTweakEntryDom_": yes
        "goog.tweak.EntriesPanel.prototype.getRootElement": yes
        "goog.tweak.EntriesPanel.prototype.insertEntry": yes
        "goog.tweak.EntriesPanel.prototype.onHelpClick_": yes
        "goog.tweak.EntriesPanel.prototype.render": yes
        "goog.tweak.EntriesPanel.prototype.showDescription_": yes
        "goog.tweak.EntriesPanel.prototype.toggleAllDescriptions": yes
        "goog.tweak.NamespaceEntry_": yes
        "goog.tweak.NamespaceEntry_.ID_PREFIX": yes
        "goog.tweak.NumericSetting": yes
        "goog.tweak.StringSetting": yes
        "goog.tweak.TweakUi": yes
        "goog.tweak.TweakUi.CSS_STYLES_": yes
        "goog.tweak.TweakUi.ENTRY_CSS_CLASSES_": yes
        "goog.tweak.TweakUi.ENTRY_CSS_CLASS_": yes
        "goog.tweak.TweakUi.ENTRY_GROUP_CSS_CLASSES_": yes
        "goog.tweak.TweakUi.ROOT_PANEL_CLASS_": yes
        "goog.tweak.TweakUi.STYLE_SHEET_INSTALLED_MARKER_": yes
        "goog.tweak.TweakUi.create": yes
        "goog.tweak.TweakUi.createCollapsible": yes
        "goog.tweak.TweakUi.entryCompare_": yes
        "goog.tweak.TweakUi.extractBooleanGroupEntries_": yes
        "goog.tweak.TweakUi.extractNamespace_": yes
        "goog.tweak.TweakUi.getNamespacedLabel_": yes
        "goog.tweak.TweakUi.isGroupEntry_": yes
        "goog.tweak.TweakUi.prototype.getRootElement": yes
        "goog.tweak.TweakUi.prototype.insertEntry_": yes
        "goog.tweak.TweakUi.prototype.installStyles_": yes
        "goog.tweak.TweakUi.prototype.onNewRegisteredEntry_": yes
        "goog.tweak.TweakUi.prototype.render": yes
        "goog.tweak.TweakUi.prototype.restartWithAppliedTweaks_": yes
        "goog.tweak.getRegistry": yes
        "goog.ui.Zippy": yes
        "goog.userAgent.IE": yes
        "goog.userAgent.MOBILE": yes
      "provides":
        "goog.tweak.EntriesPanel": yes
        "goog.tweak.TweakUi": yes
      "requires":
        "goog.object": yes
        "goog.array": yes
        "goog.asserts": yes
        "goog.dom.DomHelper": yes
        "goog.object": yes
        "goog.style": yes
        "goog.tweak": yes
        "goog.ui.Zippy": yes
        "goog.userAgent": yes

    stream = closure.analyzeFile filePath
    stream = closure.findMissingRequires stream
    stream.pipe es.map (data, cb) ->
      expect(data).to.eql expectation
      done()
      cb()

  it 'should find unnecessary requires', (done) ->
    filePath = 'tests/data/test_tweakui.js'
    expectation =
      "unnecessary":
        "goog.dom.DomHelper": yes
      "namespaces":
        "goog.array.binarySearch": yes
        "goog.array.defaultCompare": yes
        "goog.array.insertAt": yes
        "goog.asserts.assert": yes
        "goog.asserts.assertInstanceof": yes
        "goog.bind": yes
        "goog.dom.getDomHelper": yes
        "goog.dom.setTextContent": yes
        "goog.getCssName": yes
        "goog.inherits": yes
        "goog.object.getValues": yes
        "goog.style.installStyles": yes
        "goog.style.setElementShown": yes
        "goog.tweak.BaseEntry": yes
        "goog.tweak.BaseEntry.call": yes
        "goog.tweak.BooleanGroup": yes
        "goog.tweak.BooleanInGroupSetting": yes
        "goog.tweak.BooleanSetting": yes
        "goog.tweak.ButtonAction": yes
        "goog.tweak.EntriesPanel": yes
        "goog.tweak.EntriesPanel.prototype.createBooleanSettingDom_": yes
        "goog.tweak.EntriesPanel.prototype.createButtonActionDom_": yes
        "goog.tweak.EntriesPanel.prototype.createComboBoxDom_": yes
        "goog.tweak.EntriesPanel.prototype.createEntryElem_": yes
        "goog.tweak.EntriesPanel.prototype.createHelpElem_": yes
        "goog.tweak.EntriesPanel.prototype.createSubPanelDom_": yes
        "goog.tweak.EntriesPanel.prototype.createTextBoxDom_": yes
        "goog.tweak.EntriesPanel.prototype.createTweakEntryDom_": yes
        "goog.tweak.EntriesPanel.prototype.getRootElement": yes
        "goog.tweak.EntriesPanel.prototype.insertEntry": yes
        "goog.tweak.EntriesPanel.prototype.onHelpClick_": yes
        "goog.tweak.EntriesPanel.prototype.render": yes
        "goog.tweak.EntriesPanel.prototype.showDescription_": yes
        "goog.tweak.EntriesPanel.prototype.toggleAllDescriptions": yes
        "goog.tweak.NamespaceEntry_": yes
        "goog.tweak.NamespaceEntry_.ID_PREFIX": yes
        "goog.tweak.NumericSetting": yes
        "goog.tweak.StringSetting": yes
        "goog.tweak.TweakUi": yes
        "goog.tweak.TweakUi.CSS_STYLES_": yes
        "goog.tweak.TweakUi.ENTRY_CSS_CLASSES_": yes
        "goog.tweak.TweakUi.ENTRY_CSS_CLASS_": yes
        "goog.tweak.TweakUi.ENTRY_GROUP_CSS_CLASSES_": yes
        "goog.tweak.TweakUi.ROOT_PANEL_CLASS_": yes
        "goog.tweak.TweakUi.STYLE_SHEET_INSTALLED_MARKER_": yes
        "goog.tweak.TweakUi.create": yes
        "goog.tweak.TweakUi.createCollapsible": yes
        "goog.tweak.TweakUi.entryCompare_": yes
        "goog.tweak.TweakUi.extractBooleanGroupEntries_": yes
        "goog.tweak.TweakUi.extractNamespace_": yes
        "goog.tweak.TweakUi.getNamespacedLabel_": yes
        "goog.tweak.TweakUi.isGroupEntry_": yes
        "goog.tweak.TweakUi.prototype.getRootElement": yes
        "goog.tweak.TweakUi.prototype.insertEntry_": yes
        "goog.tweak.TweakUi.prototype.installStyles_": yes
        "goog.tweak.TweakUi.prototype.onNewRegisteredEntry_": yes
        "goog.tweak.TweakUi.prototype.render": yes
        "goog.tweak.TweakUi.prototype.restartWithAppliedTweaks_": yes
        "goog.tweak.getRegistry": yes
        "goog.ui.Zippy": yes
        "goog.userAgent.IE": yes
        "goog.userAgent.MOBILE": yes
      "provides":
        "goog.tweak.EntriesPanel": yes
        "goog.tweak.TweakUi": yes
      "requires":
        "goog.object": yes
        "goog.array": yes
        "goog.asserts": yes
        "goog.dom.DomHelper": yes
        "goog.object": yes
        "goog.style": yes
        "goog.tweak": yes
        "goog.ui.Zippy": yes
        "goog.userAgent": yes

    stream = closure.analyzeFile filePath
    stream = closure.findUnnecessaryRequires stream
    stream.pipe es.map (data, cb) ->
      expect(data).to.eql expectation
      done()
      cb()
