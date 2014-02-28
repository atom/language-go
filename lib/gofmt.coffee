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
    @subscribe buffer, 'will-be-saved', =>
      grammar = editor.getGrammar()
      if grammar.scopeName is 'source.go' and atom.config.get('language-go.formatOnSave')
        @formatBuffer(buffer)

  formatBuffer: (buffer) ->
    gofmt = atom.config.get('language-go.gofmtPath')
    fmt = spawn(gofmt, ["-w=true", buffer.getPath()])
