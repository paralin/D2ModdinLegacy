installingNot = null

#some kind of autorun that redirects off this page if mod is installed and manager
#is installed
Meteor.startup ->
  Meteor.autorun ->
    route = Router.current()
    return if !route?
    client = clients.findOne()
    return if !client?
    return if !(route.route.name is "install")
    return if !installingNot?
    for mod in client.installedMods
      if mod.split("=")[0] is route.params.mod
        Session.set "isDownMod", false
        Router.go("/lobbies/"+route.params.mod)
        $.pnotify
          title: "Installed"
          text: "The mod has been installed."
          delay: 5000
          type: "success"
        
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
    Meteor.call "installMod", Router.current().params.mod, (err,res)->
      if err?
        Session.set "isDownMod", false
        if err.error is 410
          Router.go("/lobbies/")
          $.pnotify
            title: "Mod Already Installed"
            text: err.reason
            type: "success"
            delay: 5000
            closer: false
            sticker: false
        else
          $.pnotify
            title: "Can't Install Mod"
            text: err.reason
            type: "error"
            nonblock: true
            closer: false
            sticker: false
      else
        installingNot = $.pnotify
          title: "Installing..."
          text: "Your manager has been told to install the mod. Please wait."
          type: "success"
          nonblock: true
          hide: false
          closer: false
          sticker: false
  "click .managerBtn": ->
    if !installingNot?
      Session.set("managerStatus", "Waiting for launcher to connect...")
      window.open "https://s3-us-west-2.amazonaws.com/d2mpclient/D2MPLauncher.exe"
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
