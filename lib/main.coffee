Gofmt = require './gofmt'

module.exports =
  configDefaults:
    formatOnSave: true
    gofmtPath: "gofmt"
    goimportsEnabled: false
    goimportsPath: "goimports"
    indentWithTabs: true
    tabWidth: 8

  activate: ->
    @gofmt = new Gofmt()
    atom.workspaceView.command "golang:gofmt", => @gofmt.formatCurrentBuffer()

  deactivate: ->
    @gofmt.destroy()
