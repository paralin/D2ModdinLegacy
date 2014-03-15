installingNot = null

#some kind of autorun that redirects off this page if mod is installed and manager
#is installed
Template.installMod.hasModManager = ->
  clients.findOne()?
Template.installMod.destroyed = ->
  if installingNot?
    installingNot.pnotify_remove() if(installingNot.pnotify_remove)
      
Template.installMod.events
  "click .installBtn": ->
    Meteor.call "installMod", modnamehere
    installingNot = $.pnotify
      title: "Installing..."
      text: "Your manager has been told to install the mod. Please wait."
      type: "success"
      nonblock: true
      hide: false
      closer: false
      sticker: false
  "click .managerBtn": ->
    Session.set("managerStatus", "Waiting for launcher to connect...")
    window.open "https://s3-us-west-2.amazonaws.com/d2mpclient/launcher.exe"
    $.pnotify
      title: "Download Started"
      text: "Run the launcher (downloading now) to finish the mod installation."
      type: "info"
      delay: 3000
      closer: false
      sticker: true
