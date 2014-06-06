installingNot = null

Template.installMod.isDownloading = ->
  Session.get "isDownMod"

Template.installMod.hasModManager = ->
  clients.findOne()?
Template.installMod.destroyed = ->
  if installingNot?
    installingNot.remove() if(installingNot.remove)
  installingNot = null
      
Template.installMod.events
  "click .installBtn": ->
    Session.set "isDownMod", true
    callMethod "installmod", {mod: Router.current().params.mod}
  "click .managerBtn": ->
    if !installingNot?
      Session.set("managerStatus", "Waiting for launcher to connect...")
      window.open "https://s3-us-west-2.amazonaws.com/d2mpclient/D2MPUpdater.exe"
      $.pnotify
        title: "Download Started"
        text: "Run the launcher (downloading now) to finish the mod installation."
        type: "info"
        delay: 3000
        closer: false
    else
      $.pnotify
        title: "Mod Already Installing"
        text: "You already clicked that button!"
        type: "error"
        delay: 1000
        closer: false
        sticker: false
