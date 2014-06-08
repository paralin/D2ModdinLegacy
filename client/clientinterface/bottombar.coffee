Session.set("botBarStatus", 0)

Meteor.startup ->
  Meteor.autorun ->
    hasClient = Session.get "clientData"
    if !client?
      Session.set("managerStatus", "Manager is not installed/not running.")
      return
    if client.status is 0
      Session.set("managerStatus", "Mod launcher running and ready.")
    else if client.status is 1
      Session.set("managerStatus", "Mod launcher out of date, run installer!")
    
UI.registerHelper "hasManager", ->
  client = Session.get "clientData"
  return client?

Template.bottomBar.showDLButton = ->
  client = Session.get "clientData"
  if !client?
    return true
  return client.status is 1

Template.bottomBar.status = ->
  Session.get("managerStatus")

events =
  "click .launchmm": ->
    Session.set("managerStatus", "Waiting for launcher to connect...")
    window.open "https://s3-us-west-2.amazonaws.com/d2mpclient/D2MPUpdater.exe"
    $.pnotify
      title: "Download Started"
      text: "Run the launcher (downloading now) to start joining lobbies."
      type: "info"
      delay: 3000
      closer: false
      sticker: true
Template.bottomBar.events events
Template.findDialog.events events
