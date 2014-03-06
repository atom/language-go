spawn = require('child_process').spawn

module.exports =
class Gofmt

  constructor: ->
    atom.workspace.eachEditor (editor) =>
      @handleBufferEvents(editor)

  handleBufferEvents: (editor) ->
    buffer = editor.getBuffer()
    buffer.on 'saved', =>
      @formatBuffer(buffer, editor, true)

  formatCurrentBuffer: ->
    editor = atom.workspace.getActiveEditor()
    @formatBuffer(editor.getBuffer(), editor, false)

  formatBuffer: (buffer, editor, saving) ->
    grammar = editor.getGrammar()
    return if saving and not atom.config.get('language-go.formatOnSave')
    return if grammar.scopeName isnt 'source.go'
    args = ["-w=true", buffer.getPath()]
    fmtCmd = atom.config.get('language-go.gofmtPath')
    fmt = spawn(fmtCmd, args)
