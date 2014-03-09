spawn = require('child_process').spawn

module.exports =
class Gofmt
  $ = require('atom').$

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
    @resetState(editor)
    args = ["-w", buffer.getPath()]
    fmtCmd = atom.config.get('language-go.gofmtPath')
    fmt = spawn(fmtCmd, args)
    fmt.on 'error', (error) -> console.log fmtCmd + ' not found'
    fmt.stderr.on 'data', (data) => @displayErrors(buffer, editor, data)
    fmt.stdout.on 'data', (data) -> console.log 'language-go:fmt: ' + data
    fmt.on 'close', (code) -> console.log fmtCmd + ' exited with code: ' + code if code isnt 0

  displayErrors: (buffer, editor, data) ->
    pattern = /^(.*?:)(\d*?):(\d*?):\s(.*)$/img
    errors = []
    extract = (matchLine) ->
      return if not matchLine?
      error = [matchLine[2], matchLine[3], matchLine[4]]
      errors.push error
    loop
      match = pattern.exec(data)
      extract(match)
      break unless match?
    @updatePane(errors)
    @updateGutter(errors)

  resetState: (editor) ->
    @updateGutter([])
    @updatePane([])

  updateGutter: (errors) ->
    atom.workspaceView.eachEditorView (editorView) =>
      return if not editorView.active
      gutter = editorView.gutter
      gutter.removeClassFromAllLines('language-go-error')
      gutter.addClassToLine error[0] - 1, 'language-go-error' for error in errors

  updatePane: (errors) ->
    $('#language-go-status-pane').remove()
    return if not errors?
    return if errors.length <= 0
    return if not atom.config.get('language-go.showErrorPanel')
    html = $('<div id="language-go-status-pane" class="language-go-pane" style="height:">');
    append = (error) ->
      html.append('Line: ' + error[0] + ' Char: ' + error[1] + ' – ' + error[2])
      html.append('<br/>')
    append error for error in errors
    atom.workspaceView.prependToBottom(html)
