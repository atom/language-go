Gofmt = require './gofmt'
Gobuild = require './gobuild'

module.exports =
  configDefaults:
    formatOnSave: true
    syntaxCheckOnSave: true
    gofmtPath: "/usr/local/go/bin/gofmt"
    goBinPath: "/usr/local/bin/go"
    showErrorPanel: true

  activate: ->
    @gofmt = new Gofmt()
    atom.workspaceView.command "golang:gofmt", => @gofmt.formatCurrentBuffer()
    @gobuild = new Gobuild()
    atom.workspaceView.command "golang:gobuild", => @gobuild.compilationCheck()

  deactivate: ->
    @gofmt.destroy()
    @gobuild.destroy()
