Template.admin.servers = ->
  servers.find()
Template.admin.events
  "click .servt tr": ->
    Router.go Router.routes["adminServer"].path {id: @_id}
Template.adminServer.events
  "click .sdBtn": ->
    id = @_id
    if !confirm 'Are you sure you want to shut down '+@ip+"?"
      return
    console.log "Requesting host shutdown for "+id
    Meteor.call "shutdownHost", id, (err, res)->
      if err?
        $.pnotify
          title: "Failed to Shutdown Host"
          text: err.reason
          type: "error"
      else
        $.pnotify
          title: "Command Sent"
          text: "Server told to shut down."
          type: "success"
  "click .rsBtn": ->
    id = @_id
    if !confirm 'Are you sure you want to kill all active servers on '+@ip+"?"
      return
    console.log "Requesting host restart for "+id
    Meteor.call "restartHost", id, (err, res)->
      if err?
        $.pnotify
          title: "Failed to Restart Host"
          text: err.reason
          type: "error"
      else
        $.pnotify
          title: "Command Sent"
          text: "Server told to restart."
          type: "success"
