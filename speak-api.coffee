module.exports = (env) ->

  convict = env.require "convict"
  Q = env.require 'q'
  assert = env.require 'cassert'

  class SpeakFrontend extends env.plugins.Plugin
    actions: []

    init: (app, server, @config) =>
      _this = this

      app.get "/api/speak", (req, res, next) ->
        query = require("url").parse(req.url, true).query
        console.log query
        if (not query?) or (typeof query["word[]"] is "undefined")
          res.send 400, "Illegal Request"
        words = query["word[]"]
        words = (if Array.isArray words then words else [words])
        found = false
        for word in words
          found = server.ruleManager.executeAction word, false, (e, message)->
            if not e? then res.send 200, message
            else res.send 200, "Ein Fehler ist aufgetreten: #{e}"
          if found then break
        unless found then res.send 200, "Nicht gefunden: #{words[0]}" 

  return new SpeakFrontend