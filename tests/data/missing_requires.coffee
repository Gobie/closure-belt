# Copyright 2009 The Closure Library Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS-IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

###*
  @fileoverview A UI for editing tweak settings / clicking tweak actions.

  @author agrieve@google.com (Andrew Grieve)
###
goog.provide "goog.tweak.EntriesPanel"
goog.provide "goog.tweak.TweakUi"
goog.require "goog.array"
goog.require "goog.asserts"
goog.require "goog.dom.DomHelper"
goog.require "goog.object"
goog.require "goog.style"
goog.require "goog.tweak"
goog.require "goog.ui.Zippy"
goog.require "goog.userAgent"

###*
  A UI for editing tweak settings / clicking tweak actions.
  @param {!goog.tweak.Registry} registry The registry to render.
  @param {goog.dom.DomHelper=} opt_domHelper The DomHelper to render with.
  @constructor
  @final
###
goog.tweak.TweakUi = (registry, opt_domHelper) ->

  ###*
    The registry to create a UI from.
    @type {!goog.tweak.Registry}
    @private
  ###
  @registry_ = registry

  ###*
    The element to display when the UI is visible.
    @type {goog.tweak.EntriesPanel|undefined}
    @private
  ###
  @entriesPanel_

  ###*
    The DomHelper to render with.
    @type {!goog.dom.DomHelper}
    @private
  ###
  @domHelper_ = opt_domHelper or goog.dom.getDomHelper()

  # Listen for newly registered entries (happens with lazy-loaded modules).
  registry.addOnRegisterListener goog.bind(@onNewRegisteredEntry_, this)
  return


###*
  The CSS class name unique to the root tweak panel div.
  @type {string}
  @private
###
goog.tweak.TweakUi.ROOT_PANEL_CLASS_ = goog.getCssName("goog-tweak-root")

###*
  The CSS class name unique to the tweak entry div.
  @type {string}
  @private
###
goog.tweak.TweakUi.ENTRY_CSS_CLASS_ = goog.getCssName("goog-tweak-entry")

###*
  The CSS classes for each tweak entry div.
  @type {string}
  @private
###
goog.tweak.TweakUi.ENTRY_CSS_CLASSES_ = goog.tweak.TweakUi.ENTRY_CSS_CLASS_ + " " + goog.getCssName("goog-inline-block")

###*
  The CSS classes for each namespace tweak entry div.
  @type {string}
  @private
###
goog.tweak.TweakUi.ENTRY_GROUP_CSS_CLASSES_ = goog.tweak.TweakUi.ENTRY_CSS_CLASS_

###*
  Marker that the style sheet has already been installed.
  @type {string}
  @private
###
goog.tweak.TweakUi.STYLE_SHEET_INSTALLED_MARKER_ = "__closure_tweak_installed_"

###*
  CSS used by TweakUI.
  @type {string}
  @private
###
goog.tweak.TweakUi.CSS_STYLES_ = (->
  MOBILE = goog.userAgent.MOBILE
  IE = goog.userAgent.IE
  ENTRY_CLASS = "." + goog.tweak.TweakUi.ENTRY_CSS_CLASS_
  ROOT_PANEL_CLASS = "." + goog.tweak.TweakUi.ROOT_PANEL_CLASS_
  GOOG_INLINE_BLOCK_CLASS = "." + goog.getCssName("goog-inline-block")
  ret = ROOT_PANEL_CLASS + "{background:#ffc; padding:0 4px}"

  # Make this work even if the user hasn't included common.css.
  ret += GOOG_INLINE_BLOCK_CLASS + "{display:inline-block}"  unless IE

  # Space things out vertically for touch UIs.
  ret += ROOT_PANEL_CLASS + "," + ROOT_PANEL_CLASS + " fieldset{" + "line-height:2em;" + "}"  if MOBILE
  ret
)()

###*
  Creates a TweakUi if tweaks are enabled.
  @param {goog.dom.DomHelper=} opt_domHelper The DomHelper to render with.
  @return {!Element|undefined} The root UI element or undefined if tweaks are
  not enabled.
###
goog.tweak.TweakUi.create = (opt_domHelper) ->
  registry = goog.tweak.getRegistry()
  if registry
    ui = new goog.tweak.TweakUi(registry, opt_domHelper)
    ui.render()
    ui.getRootElement()


###*
  Creates a TweakUi inside of a show/hide link.
  @param {goog.dom.DomHelper=} opt_domHelper The DomHelper to render with.
  @return {!Element|undefined} The root UI element or undefined if tweaks are
  not enabled.
###
goog.tweak.TweakUi.createCollapsible = (opt_domHelper) ->
  registry = goog.tweak.getRegistry()
  if registry
    dh = opt_domHelper or goog.dom.getDomHelper()

    # The following strings are for internal debugging only.  No translation
    # necessary.  Do NOT wrap goog.getMsg() around these strings.
    showLink = dh.createDom("a",
      href: "javascript:;"
    , "Show Tweaks")
    hideLink = dh.createDom("a",
      href: "javascript:;"
    , "Hide Tweaks")
    ret = dh.createDom("div", null, showLink)
    lazyCreate = ->

      # Lazily render the UI.
      ui = new goog.tweak.TweakUi((registry), dh)
      ui.render()

      # Put the hide link on the same line as the "Show Descriptions" link.
      # Set the style lazily because we can.
      hideLink.style.marginRight = "10px"
      tweakElem = ui.getRootElement()
      tweakElem.insertBefore hideLink, tweakElem.firstChild
      ret.appendChild tweakElem
      tweakElem

    new goog.ui.Zippy(showLink, lazyCreate, false, hideLink) # expanded
    ret


###*
  Compares the given entries. Orders alphabetically and groups buttons and
  expandable groups.
  @param {goog.tweak.BaseEntry} a The first entry to compare.
  @param {goog.tweak.BaseEntry} b The second entry to compare.
  @return {number} Refer to goog.array.defaultCompare.
  @private
###
goog.tweak.TweakUi.entryCompare_ = (a, b) ->
  goog.array.defaultCompare(a instanceof goog.tweak.NamespaceEntry_, b instanceof goog.tweak.NamespaceEntry_) or goog.array.defaultCompare(a instanceof goog.tweak.BooleanGroup, b instanceof goog.tweak.BooleanGroup) or goog.array.defaultCompare(a instanceof goog.tweak.ButtonAction, b instanceof goog.tweak.ButtonAction) or goog.array.defaultCompare(a.label, b.label) or goog.array.defaultCompare(a.getId(), b.getId())


###*
  @param {!goog.tweak.BaseEntry} entry The entry.
  @return {boolean} Returns whether the given entry contains sub-entries.
  @private
###
goog.tweak.TweakUi.isGroupEntry_ = (entry) ->
  entry instanceof goog.tweak.NamespaceEntry_ or entry instanceof goog.tweak.BooleanGroup


###*
  Returns the list of entries from the given boolean group.
  @param {!goog.tweak.BooleanGroup} group The group to get the entries from.
  @return {!Array.<!goog.tweak.BaseEntry>} The sorted entries.
  @private
###
goog.tweak.TweakUi.extractBooleanGroupEntries_ = (group) ->
  ret = goog.object.getValues(group.getChildEntries())
  ret.sort goog.tweak.TweakUi.entryCompare_
  ret


###*
  @param {!goog.tweak.BaseEntry} entry The entry.
  @return {string} Returns the namespace for the entry, or '' if it is not
  namespaced.
  @private
###
goog.tweak.TweakUi.extractNamespace_ = (entry) ->
  namespaceMatch = /.+(?=\.)/.exec(entry.getId())
  (if namespaceMatch then namespaceMatch[0] else "")


###*
  @param {!goog.tweak.BaseEntry} entry The entry.
  @return {string} Returns the part of the label after the last period, unless
  the label has been explicly set (it is different from the ID).
  @private
###
goog.tweak.TweakUi.getNamespacedLabel_ = (entry) ->
  label = entry.label
  label = label.substr(label.lastIndexOf(".") + 1)  if label is entry.getId()
  label


###*
  @return {!Element} The root element. Must not be called before render().
###
goog.tweak.TweakUi::getRootElement = ->
  goog.asserts.assert @entriesPanel_, "TweakUi.getRootElement called before render()."
  @entriesPanel_.getRootElement()


###*
  Reloads the page with query parameters set by the UI.
  @private
###
goog.tweak.TweakUi::restartWithAppliedTweaks_ = ->
  queryString = @registry_.makeUrlQuery()
  wnd = @domHelper_.getWindow()
  unless queryString is wnd.location.search
    wnd.location.search = queryString
  else
    wnd.location.reload()
  return


###*
  Installs the required CSS styles.
  @private
###
goog.tweak.TweakUi::installStyles_ = ->

  # Use an marker to install the styles only once per document.
  # Styles are injected via JS instead of in a separate style sheet so that
  # they are automatically excluded when tweaks are stripped out.
  doc = @domHelper_.getDocument()
  unless goog.tweak.TweakUi.STYLE_SHEET_INSTALLED_MARKER_ of doc
    goog.style.installStyles goog.tweak.TweakUi.CSS_STYLES_, doc
    doc[goog.tweak.TweakUi.STYLE_SHEET_INSTALLED_MARKER_] = true
  return


###*
  Creates the element to display when the UI is visible.
  @return {!Element} The root element.
###
goog.tweak.TweakUi::render = ->
  @installStyles_()
  dh = @domHelper_

  # The submit button
  submitButton = dh.createDom("button",
    style: "font-weight:bold"
  , "Apply Tweaks")
  submitButton.onclick = goog.bind(@restartWithAppliedTweaks_, this)
  rootPanel = new goog.tweak.EntriesPanel([], dh)
  rootPanelDiv = rootPanel.render(submitButton)
  rootPanelDiv.className += " " + goog.tweak.TweakUi.ROOT_PANEL_CLASS_
  @entriesPanel_ = rootPanel
  # excludeChildEntries
  entries = @registry_.extractEntries(true, false) # excludeNonSettings
  i = 0
  entry = undefined

  while entry = entries[i]
    @insertEntry_ entry
    i++
  rootPanelDiv


###*
  Updates the UI with the given entry.
  @param {!goog.tweak.BaseEntry} entry The newly registered entry.
  @private
###
goog.tweak.TweakUi::onNewRegisteredEntry_ = (entry) ->
  @insertEntry_ entry  if @entriesPanel_
  return


###*
  Updates the UI with the given entry.
  @param {!goog.tweak.BaseEntry} entry The newly registered entry.
  @private
###
goog.tweak.TweakUi::insertEntry_ = (entry) ->
  panel = @entriesPanel_
  namespace = goog.tweak.TweakUi.extractNamespace_(entry)
  if namespace

    # Find the NamespaceEntry that the entry belongs to.
    namespaceEntryId = goog.tweak.NamespaceEntry_.ID_PREFIX + namespace
    nsPanel = panel.childPanels[namespaceEntryId]
    if nsPanel
      panel = nsPanel
    else
      entry = new goog.tweak.NamespaceEntry_(namespace, [entry])
  if entry instanceof goog.tweak.BooleanInGroupSetting
    group = entry.getGroup()

    # BooleanGroup entries are always registered before their
    # BooleanInGroupSettings.
    panel = panel.childPanels[group.getId()]
  goog.asserts.assert panel, "Missing panel for entry %s", entry.getId()
  panel.insertEntry entry
  return


###*
  The body of the tweaks UI and also used for BooleanGroup.
  @param {!Array.<!goog.tweak.BaseEntry>} entries The entries to show in the
  panel.
  @param {goog.dom.DomHelper=} opt_domHelper The DomHelper to render with.
  @constructor
  @final
###
goog.tweak.EntriesPanel = (entries, opt_domHelper) ->

  ###*
    The entries to show in the panel.
    @type {!Array.<!goog.tweak.BaseEntry>} entries
    @private
  ###
  @entries_ = entries
  self = this

  ###*
    The bound onclick handler for the help question marks.
    @this {Element}
    @private
  ###
  @boundHelpOnClickHandler_ = ->
    self.onHelpClick_ @parentNode
    return


  ###*
    The element that contains the UI.
    @type {Element}
    @private
  ###
  @rootElem_

  ###*
    The element that contains all of the settings and the endElement.
    @type {Element}
    @private
  ###
  @mainPanel_

  ###*
    Flips between true/false each time the "Toggle Descriptions" link is
    clicked.
    @type {boolean}
    @private
  ###
  @showAllDescriptionsState_

  ###*
    The DomHelper to render with.
    @type {!goog.dom.DomHelper}
    @private
  ###
  @domHelper_ = opt_domHelper or goog.dom.getDomHelper()

  ###*
    Map of tweak ID -> EntriesPanel for child panels (BooleanGroups).
    @type {!Object.<!goog.tweak.EntriesPanel>}
  ###
  @childPanels = {}
  return


###*
  @return {!Element} Returns the expanded element. Must not be called before
  render().
###
goog.tweak.EntriesPanel::getRootElement = ->
  goog.asserts.assert @rootElem_, "EntriesPanel.getRootElement called before render()."
  @rootElem_


###*
  Creates and returns the expanded element.
  The markup looks like:
  <div>
  <a>Show Descriptions</a>
  <div>
  ...
  {endElement}
  </div>
  </div>
  @param {Element|DocumentFragment=} opt_endElement Element to insert after all
  tweak entries.
  @return {!Element} The root element for the panel.
###
goog.tweak.EntriesPanel::render = (opt_endElement) ->
  dh = @domHelper_
  entries = @entries_
  ret = dh.createDom("div")
  showAllDescriptionsLink = dh.createDom("a",
    href: "javascript:;"
    onclick: goog.bind(@toggleAllDescriptions, this)
  , "Toggle all Descriptions")
  ret.appendChild showAllDescriptionsLink

  # Add all of the entries.
  mainPanel = dh.createElement("div")
  @mainPanel_ = mainPanel
  i = 0
  entry = undefined

  while entry = entries[i]
    mainPanel.appendChild @createEntryElem_(entry)
    i++
  mainPanel.appendChild opt_endElement  if opt_endElement
  ret.appendChild mainPanel
  @rootElem_ = ret
  ret

###*
  Inserts the given entry into the panel.
  @param {!goog.tweak.BaseEntry} entry The entry to insert.
###
goog.tweak.EntriesPanel::insertEntry = (entry) ->
  insertIndex = -goog.array.binarySearch(@entries_, entry, goog.tweak.TweakUi.entryCompare_) - 1
  goog.asserts.assert insertIndex >= 0, "insertEntry failed for %s", entry.getId()
  goog.array.insertAt @entries_, entry, insertIndex

  # IE doesn't like 'undefined' here.
  @mainPanel_.insertBefore @createEntryElem_(entry), @mainPanel_.childNodes[insertIndex] or null
  return


###*
  Creates and returns a form element for the given entry.
  @param {!goog.tweak.BaseEntry} entry The entry.
  @return {!Element} The root DOM element for the entry.
  @private
###
goog.tweak.EntriesPanel::createEntryElem_ = (entry) ->
  dh = @domHelper_
  isGroupEntry = goog.tweak.TweakUi.isGroupEntry_(entry)
  classes = (if isGroupEntry then goog.tweak.TweakUi.ENTRY_GROUP_CSS_CLASSES_ else goog.tweak.TweakUi.ENTRY_CSS_CLASSES_)

  # Containers should not use label tags or else all descendent inputs will be
  # connected on desktop browsers.
  containerNodeName = (if isGroupEntry then "span" else "label")
  ret = dh.createDom("div", classes, dh.createDom(containerNodeName,

    # Make the hover text the description.
    title: entry.description
    style: "color:" + ((if entry.isRestartRequired() then "" else "blue"))

  # Add the expandable help question mark.
  , @createTweakEntryDom_(entry)), @createHelpElem_(entry))
  ret


###*
  Click handler for the help link.
  @param {Node} entryDiv The div that contains the tweak.
  @private
###
goog.tweak.EntriesPanel::onHelpClick_ = (entryDiv) ->
  @showDescription_ entryDiv, not entryDiv.style.display
  return


###*
  Twiddle the DOM so that the entry within the given span is shown/hidden.
  @param {Node} entryDiv The div that contains the tweak.
  @param {boolean} show True to show, false to hide.
  @private
###
goog.tweak.EntriesPanel::showDescription_ = (entryDiv, show) ->
  descriptionElem = entryDiv.lastChild.lastChild
  goog.style.setElementShown (descriptionElem), show
  entryDiv.style.display = (if show then "block" else "")
  return


###*
  Creates and returns a help element for the given entry.
  @param {goog.tweak.BaseEntry} entry The entry.
  @return {!Element} The root element of the created DOM.
  @private
###
goog.tweak.EntriesPanel::createHelpElem_ = (entry) ->

  # The markup looks like:
  # <span onclick=...><b>?</b><span>{description}</span></span>
  ret = @domHelper_.createElement("span")
  ret.innerHTML = "<b style=\"padding:0 1em 0 .5em\">?</b>" + "<span style=\"display:none;color:#666\"></span>"
  ret.onclick = @boundHelpOnClickHandler_
  descriptionElem = ret.lastChild
  goog.dom.setTextContent (descriptionElem), entry.description
  descriptionElem.innerHTML += " <span style=\"color:blue\">(no restart required)</span>"  unless entry.isRestartRequired()
  ret


###*
  Show all entry descriptions (has the same effect as clicking on all ?'s).
###
goog.tweak.EntriesPanel::toggleAllDescriptions = ->
  show = not @showAllDescriptionsState_
  @showAllDescriptionsState_ = show
  entryDivs = @domHelper_.getElementsByTagNameAndClass("div", goog.tweak.TweakUi.ENTRY_CSS_CLASS_, @rootElem_)
  i = 0
  div = undefined

  while div = entryDivs[i]
    @showDescription_ div, show
    i++
  return


###*
  Creates the DOM element to control the given enum setting.
  @param {!goog.tweak.StringSetting|!goog.tweak.NumericSetting} tweak The
  setting.
  @param {string} label The label for the entry.
  @param {!Function} onchangeFunc onchange event handler.
  @return {!DocumentFragment} The DOM element.
  @private
###
goog.tweak.EntriesPanel::createComboBoxDom_ = (tweak, label, onchangeFunc) ->

  # The markup looks like:
  # Label: <select><option></option></select>
  dh = @domHelper_
  ret = dh.getDocument().createDocumentFragment()
  ret.appendChild dh.createTextNode(label + ": ")
  selectElem = dh.createElement("select")
  values = tweak.getValidValues()
  i = 0
  il = values.length

  while i < il
    optionElem = dh.createElement("option")
    optionElem.text = String(values[i])

    # Setting the option tag's value is required for selectElem.value to work
    # properly.
    optionElem.value = String(values[i])
    selectElem.appendChild optionElem
    ++i
  ret.appendChild selectElem

  # Set the value and add a callback.
  selectElem.value = tweak.getNewValue()
  selectElem.onchange = onchangeFunc
  tweak.addCallback ->
    selectElem.value = tweak.getNewValue()
    return

  ret


###*
  Creates the DOM element to control the given boolean setting.
  @param {!goog.tweak.BooleanSetting} tweak The setting.
  @param {string} label The label for the entry.
  @return {!DocumentFragment} The DOM elements.
  @private
###
goog.tweak.EntriesPanel::createBooleanSettingDom_ = (tweak, label) ->
  dh = @domHelper_
  ret = dh.getDocument().createDocumentFragment()
  checkbox = dh.createDom("input",
    type: "checkbox"
  )
  ret.appendChild checkbox
  ret.appendChild dh.createTextNode(label)

  # Needed on IE6 to ensure the textbox doesn't get cleared
  # when added to the DOM.
  checkbox.defaultChecked = tweak.getNewValue()
  checkbox.checked = tweak.getNewValue()
  checkbox.onchange = ->
    tweak.setValue checkbox.checked
    return

  tweak.addCallback ->
    checkbox.checked = tweak.getNewValue()
    return

  ret


###*
  Creates the DOM for a BooleanGroup or NamespaceEntry.
  @param {!goog.tweak.BooleanGroup|!goog.tweak.NamespaceEntry_} entry The
  entry.
  @param {string} label The label for the entry.
  @param {!Array.<goog.tweak.BaseEntry>} childEntries The child entries.
  @return {!DocumentFragment} The DOM element.
  @private
###
goog.tweak.EntriesPanel::createSubPanelDom_ = (entry, label, childEntries) ->
  dh = @domHelper_
  toggleLink = dh.createDom("a",
    href: "javascript:;"
  , label + " »")
  toggleLink2 = dh.createDom("a",
    href: "javascript:;"
  , "« " + label)
  toggleLink2.style.marginRight = "10px"
  innerUi = new goog.tweak.EntriesPanel(childEntries, dh)
  @childPanels[entry.getId()] = innerUi
  elem = innerUi.render()

  # Move the toggle descriptions link into the legend.
  descriptionsLink = elem.firstChild
  childrenElem = dh.createDom("fieldset", goog.getCssName("goog-inline-block"), dh.createDom("legend", null, toggleLink2, descriptionsLink), elem)
  # expanded
  new goog.ui.Zippy(toggleLink, childrenElem, false, toggleLink2)
  ret = dh.getDocument().createDocumentFragment()
  ret.appendChild toggleLink
  ret.appendChild childrenElem
  ret


###*
  Creates the DOM element to control the given string setting.
  @param {!goog.tweak.StringSetting|!goog.tweak.NumericSetting} tweak The
  setting.
  @param {string} label The label for the entry.
  @param {!Function} onchangeFunc onchange event handler.
  @return {!DocumentFragment} The DOM element.
  @private
###
goog.tweak.EntriesPanel::createTextBoxDom_ = (tweak, label, onchangeFunc) ->
  dh = @domHelper_
  ret = dh.getDocument().createDocumentFragment()
  ret.appendChild dh.createTextNode(label + ": ")
  textBox = dh.createDom("input",
    value: tweak.getNewValue()

    # TODO(agrieve): Make size configurable or autogrow.
    size: 5
    onblur: onchangeFunc
  )
  ret.appendChild textBox
  tweak.addCallback ->
    textBox.value = tweak.getNewValue()
    return

  ret


###*
  Creates the DOM element to control the given button action.
  @param {!goog.tweak.ButtonAction} tweak The action.
  @param {string} label The label for the entry.
  @return {!Element} The DOM element.
  @private
###
goog.tweak.EntriesPanel::createButtonActionDom_ = (tweak, label) ->
  @domHelper_.createDom "button",
    onclick: goog.bind(tweak.fireCallbacks, tweak)
  , label


###*
  Creates the DOM element to control the given entry.
  @param {!goog.tweak.BaseEntry} entry The entry.
  @return {!Element|!DocumentFragment} The DOM element.
  @private
###
goog.tweak.EntriesPanel::createTweakEntryDom_ = (entry) ->
  label = goog.tweak.TweakUi.getNamespacedLabel_(entry)
  if entry instanceof goog.tweak.BooleanSetting
    return @createBooleanSettingDom_(entry, label)
  else if entry instanceof goog.tweak.BooleanGroup
    childEntries = goog.tweak.TweakUi.extractBooleanGroupEntries_(entry)
    return @createSubPanelDom_(entry, label, childEntries)
  else if entry instanceof goog.tweak.StringSetting

    ###*
    @this {Element}
    ###
    setValueFunc = ->
      entry.setValue @value
      return

    return (if entry.getValidValues() then @createComboBoxDom_(entry, label, setValueFunc) else @createTextBoxDom_(entry, label, setValueFunc))
  else if entry instanceof goog.tweak.NumericSetting
    setValueFunc = ->

      # Reset the value if it's not a number.
      if isNaN(@value)
        @value = entry.getNewValue()
      else
        entry.setValue +@value
      return

    return (if entry.getValidValues() then @createComboBoxDom_(entry, label, setValueFunc) else @createTextBoxDom_(entry, label, setValueFunc))
  else return @createSubPanelDom_(entry, entry.label, entry.entries)  if entry instanceof goog.tweak.NamespaceEntry_
  goog.asserts.assertInstanceof entry, goog.tweak.ButtonAction, "invalid entry: %s", entry
  @createButtonActionDom_ (entry), label


###*
  Entries used to represent the collapsible namespace links. These entries are
  never registered with the TweakRegistry, but are contained within the
  collection of entries within TweakPanels.
  @param {string} namespace The namespace for the entry.
  @param {!Array.<!goog.tweak.BaseEntry>} entries Entries within the namespace.
  @constructor
  @extends {goog.tweak.BaseEntry}
  @private
###
goog.tweak.NamespaceEntry_ = (namespace, entries) ->
  goog.tweak.BaseEntry.call this, goog.tweak.NamespaceEntry_.ID_PREFIX + namespace, "Tweaks within the " + namespace + " namespace."

  ###*
    Entries within this namespace.
    @type {!Array.<!goog.tweak.BaseEntry>}
  ###
  @entries = entries
  @label = namespace
  return

goog.inherits goog.tweak.NamespaceEntry_, goog.tweak.BaseEntry

###*
  Prefix for the IDs of namespace entries used to ensure that they do not
  conflict with regular entries.
  @type {string}
###
goog.tweak.NamespaceEntry_.ID_PREFIX = "!"