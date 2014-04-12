Template.admin.pendLobbies = ->
  lobbies.find({status: {$lt: 3}})
Template.admin.playingLobbies = ->
  lobbies.find({status: 3})
Template.admin.servers = ->
  servers.find()
Template.admin.events
  "click .servt tr": ->
    Router.go Router.routes["adminServer"].path {id: @_id}

Template.adminServer.resolvLob = ->
  lobbies.findOne({_id: @lobby})

showNiceNot = (err, res)->
  if err?
    $.pnotify
      title: "Command Failed"
      text: err.reason
      type: "error"
  else
    $.pnotify
      title: "Command Sent"
      text: "Your command has completed without errors."
      type: "success"
Template.adminServer.events
  "click .plbSdn": ->
    id = @_id
    if !confirm 'Are you sure you want to disband this perfectly decent lobby?'
      $.pnotify
        title: "Didn't Think So"
        text: "They seem just fine, don't worry."
        type: "success"
      return
    Meteor.call "shutdownLobby", id, showNiceNot
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
