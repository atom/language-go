Gofmt = require './gofmt'

module.exports =
  configDefaults:
    formatOnSave: false
    gofmtPath: "/usr/bin/gofmt"

  activate: ->
    @gofmt = new Gofmt()

  deactivate: ->
    @gofmt.destroy()
