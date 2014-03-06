Gofmt = require './gofmt'

module.exports =
  configDefaults:
    formatOnSave: true
    gofmtPath: "gofmt"

  activate: ->
    @gofmt = new Gofmt()
    atom.workspaceView.command "golang:gofmt", => @gofmt.formatCurrentBuffer()

  deactivate: ->
    @gofmt.destroy()
