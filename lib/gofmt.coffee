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
    args = ["-w", buffer.getPath()]
    fmtCmd = atom.config.get('language-go.gofmtPath')
    fmt = spawn(fmtCmd, args)
    fmt.on 'error', (error) -> console.log fmtCmd + ' not found'
    fmt.stderr.on 'data', (data) -> console.log 'error formatting file: ' + data
    fmt.stdout.on 'data', (data) -> console.log 'formatting file: ' + data
    fmt.on 'close', (code) -> console.log fmtCmd + ' exited with code: ' + code if code isnt 0
