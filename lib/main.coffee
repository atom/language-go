Gofmt = require './gofmt'

module.exports =
  configDefaults:
    formatOnSave: false
    gofmtPath: "/usr/bin/gofmt"

  activate: ->
    @gofmt = new Gofmt()
    atom.workspaceView.command "golang:gofmt", => @gofmt.formatCurrentBuffer()

  deactivate: ->
    @gofmt.destroy()
