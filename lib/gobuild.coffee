spawn = require('child_process').spawn

module.exports =
class Gobuild
  $ = require('atom').$

  constructor: ->
    atom.workspace.eachEditor (editor) =>
      @handleBufferEvents(editor)

  handleBufferEvents: (editor) ->
    buffer = editor.getBuffer()
    buffer.on 'saved', =>
      @compilationCheck(buffer, editor)

  compilationCheck: (buffer, editor) ->
    grammar = editor.getGrammar()
    return if not atom.config.get('language-go.syntaxCheckOnSave')
    return if grammar.scopeName isnt 'source.go'
    @resetState(editor)
    re = new RegExp(buffer.getBaseName()+"$");
    binCmd = atom.config.get('language-go.goBinPath')
    path = buffer.getPath().replace(re, "")
    args = ["build", "."]
    console.log binCmd, args, {cwd: path}
    compile = spawn(binCmd, args, {cwd: path})
    compile.on 'error', (error) -> console.log 'language-go: error launching build command [' + fmtCmd + '] – ' + error  + ' – current PATH: [' + process.env.PATH + ']' #if error?
    compile.stderr.on 'data', (data) => @displayErrors(buffer, editor, data)
    compile.stdout.on 'data', (data) -> console.log 'language-go: build – ' + data #if data?
    compile.on 'close', (code) -> console.log binCmd + 'language-go: build – exited with code [' + code + ']' if code isnt 0

  displayErrors: (buffer, editor, data) ->
    console.log "displayErrors"
    console.log data.toString()
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
