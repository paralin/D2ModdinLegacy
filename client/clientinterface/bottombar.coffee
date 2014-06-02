Session.set("botBarStatus", 0)

Meteor.startup ->
  Meteor.autorun ->
    client = clients.findOne()
    if !client?
      Session.set("managerStatus", "Manager is not installed/not running.")
      return
    if client.status is 0
      Session.set("managerStatus", "Mod launcher running and ready.")
    else if client.status is 1
      Session.set("managerStatus", "Mod launcher out of date, run installer!")
    
Template.bottomBar.showDLButton = ->
  client = clients.findOne()
  if !client?
    return true
  return client.status is 1

Template.bottomBar.status = ->
  Session.get("managerStatus")

Template.bottomBar.events
  "click .launchmm": ->
    Session.set("managerStatus", "Waiting for launcher to connect...")
    window.open "https://s3-us-west-2.amazonaws.com/d2mpclient/D2MPLauncher.exe"
    $.pnotify
      title: "Download Started"
      text: "Run the launcher (downloading now) to start joining lobbies."
      type: "info"
      delay: 3000
      closer: false
      sticker: true
