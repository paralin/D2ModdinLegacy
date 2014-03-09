#0 = download and launch layout
Session.set("botBarStatus", 0)
Meteor.startup ->
  Session.set("managerStatus", "Manager is not installed/not running.")

Template.bottomBar.status = ->
  Session.get("managerStatus")

Template.bottomBar.events
  "click .launchmm": ->
    Session.set("managerStatus", "Waiting for launcher to connect...")
    $.pnotify
      title: "Download Started"
      text: "Run the launcher (downloading now) to start joining lobbies."
      type: "info"
      delay: 3000
      closer: false
      sticker: true
