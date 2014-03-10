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
    goPath = atom.config.get("language-go.goPath")
    if goPath == ""
      alert("To verify the syntax of this Go file,
        you first need to set your Go Path in the Go language settings.")
      return
    @resetState(editor)
    re = new RegExp(buffer.getBaseName()+"$");
    binCmd = atom.config.get('language-go.goBinPath')
    path = buffer.getPath().replace(re, "")
    args = ["build", "."]
    env = process.env
    env["GOPATH"] = goPath
    compile = spawn(binCmd, args, {cwd: path, env: env})
    compile.on 'error', (error) -> console.log 'language-go: error launching build command [' + fmtCmd + '] – ' + error  + ' – current PATH: [' + process.env.PATH + ']' #if error?
    compile.stderr.on 'data', (data) => @displayErrors(buffer, editor, data)
    compile.stdout.on 'data', (data) -> console.log 'language-go: build – ' + data if data?
    compile.on 'close', (code) -> console.log binCmd + 'language-go: build – exited with code [' + code + ']' if code isnt 0

  displayErrors: (buffer, editor, data) ->
    output = data.toString().split("\n")
    # TODO
    pattern = /^\.*\/*(.*?):(\d*?):\s(.*)$/img
    errors = []
    extract = (matchLine) ->
      return unless matchLine?
      # file, line #, error
      error = [matchLine[1], matchLine[2], matchLine[3]]
      console.log error
      errors.push error
    output.forEach (line, i) ->
      if line.length > 0
        match = pattern.exec(line)
        extract(match)
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
      gutter.addClassToLine error[1] - 1, 'language-go-error' for error in errors

  updatePane: (errors) ->
    $('#language-go-status-pane').remove()
    return if not errors?
    return if errors.length <= 0
    return if not atom.config.get('language-go.showErrorPanel')
    html = $('<div id="language-go-status-pane" class="language-go-pane" style="height:">');
    errors.forEach (error, i) ->
      html.append(error[0] + ' Line: ' + error[1] + ' – <span class="text-error">' + error[2] + "</span>")
      html.append('<br/>')
    atom.workspaceView.prependToBottom(html)
