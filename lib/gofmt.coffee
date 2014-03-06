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
      args = ["-w=true", buffer.getPath()]
      fmtCmd = ''
      if atom.config.get('language-go.goimportsEnabled')
        fmtCmd = atom.config.get('language-go.goimportsPath')
      else
        fmtCmd = atom.config.get('language-go.gofmtPath')
      fmt = spawn(fmtCmd, args)
