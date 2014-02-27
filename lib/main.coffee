Gofmt = require './gofmt'

module.exports =
  configDefaults:
    gofmtPath: "/usr/bin/gofmt"

  activate: ->
    @gofmt = new Gofmt()

  deactivate: ->
    @gofmt.destroy()
