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
      @formatBuffer(buffer, editor, true)

  formatCurrentBuffer: ->
    editor = atom.workspace.getActiveEditor()
    @formatBuffer(editor.getBuffer(), editor, false)

  formatBuffer: (buffer, editor, saving) ->
    grammar = editor.getGrammar()
    if saving and not atom.config.get('language-go.formatOnSave')
      return
    if grammar.scopeName isnt 'source.go'
      return
    args = ["-w=true", buffer.getPath()]
    fmtCmd = atom.config.get('language-go.gofmtPath')
    fmt = spawn(fmtCmd, args)
