{Subscriber} = require 'emissary'
spawn = require('child_process').spawn

module.exports =
class Gofmt
  Subscriber.includeInto(this)

  constructor: ->
    atom.workspace.eachEditor (editor) =>
      @handleBufferEvents(editor)

  destroy: ->
    @unsubscribe()

  handleBufferEvents: (editor) ->
    buffer = editor.getBuffer()
    @subscribe buffer, 'saved', =>
      @formatBuffer(buffer, editor)

  formatCurrentBuffer: ->
    editor = atom.workspace.activePaneItem
    @formatBuffer(editor.getBuffer(), editor)

  formatBuffer: (buffer, editor) ->
    grammar = editor.getGrammar()
    if grammar.scopeName is 'source.go' and atom.config.get('language-go.formatOnSave')
      gofmt = atom.config.get('language-go.gofmtPath')
      tabs = atom.config.get('language-go.indentWithTabs')
      tabWidth = atom.config.get('language-go.tabWidth')
      args = ["-w=true", "-tabs="+tabs, "-tabwidth="+tabWidth, buffer.getPath()]
      fmt = spawn(gofmt, args)
