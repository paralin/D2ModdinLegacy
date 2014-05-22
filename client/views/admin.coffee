Template.admin.pendLobbies = ->
  lobbies.find({status: {$lt: 3}})
Template.admin.playingLobbies = ->
  lobbies.find({status: 3})
Template.admin.serverAddons = ->
  ServerAddons.find()
Template.admin.servers = ->
  servers.find()
Template.admin.events
  "click .disableSignups": ->
    Meteor.call "toggleSignups", showNiceNot
  "click .servt tr": ->
    Router.go Router.routes["adminServer"].path {id: @_id}
  "click .plbSdn": ->
    id = @_id
    if !confirm 'Are you sure you want to disband this perfectly decent lobby?'
      $.pnotify
        title: "Didn't Think So"
        text: "They seem just fine, don't worry."
        type: "success"
      return
    Meteor.call "shutdownLobby", id, showNiceNot
  "click .albSdn": ->
    id = @_id
    if !confirm 'Are you sure you want to end this in-progress game?'
      return
    Meteor.call "shutdownLobby", id, showNiceNot

Template.adminServer.resolvLob = ->
  lobbies.findOne({_id: @lobby})

@showNiceNot = (err, res)->
  if err?
    $.pnotify
      title: "Command Failed"
      text: err.reason
      type: "error"
  else
    $.pnotify
      title: "Command Sent"
      text: res || "Your command has completed without errors."
      type: "success"

Template.admin.disabledClass = ->
  enabled = @enabled
  "disabled" if enabled? && !enabled
  false
Template.adminServer.events
  "click .setLobC": ->
    id = @_id
    bootbox.prompt
      title: "How many lobbies can this server handle?"
      value: @maxLobbies
      callback: (res)->
        return if !res?
        Meteor.call "setMaxLobbies", id, parseInt(res), showNiceNot
  "click .dbBtn": ->
    id = @_id
    Meteor.call "toggleServerEnabled", id
  "click .sdBtn": ->
    id = @_id
    if !confirm 'Are you sure you want to shut down '+@ip+"?"
      return
    console.log "Requesting host shutdown for "+id
    Meteor.call "shutdownHost", id, showNiceNot
  "click .rsBtn": ->
    id = @_id
    if !confirm 'Are you sure you want to kill all active servers on '+@ip+"?"
      return
    console.log "Requesting host restart for "+id
    Meteor.call "restartHost", id, showNiceNot
  "click .sdLob": ->
    id = @_id
    if !confirm 'Are you sure you want to shutdown '+@name+"?"
      return
    console.log "Requesting host restart for "+id
    Meteor.call "shutdownLobby", id, showNiceNot
