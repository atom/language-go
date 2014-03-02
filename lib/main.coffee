Gofmt = require './gofmt'

module.exports =
  configDefaults:
    formatOnSave: false
    gofmtPath: "/usr/bin/gofmt"
    indentWithTabs: true
    tabWidth: 8

  activate: ->
    @gofmt = new Gofmt()
    atom.workspaceView.command "golang:gofmt", => @gofmt.formatCurrentBuffer()

  deactivate: ->
    @gofmt.destroy()
