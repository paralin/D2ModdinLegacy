Template.admin.servers = ->
  servers.find()
Template.admin.events
  "click .servt tr": ->
    Router.go Router.routes["adminServer"].path {id: @_id}
Template.adminServer.events
  "click .sdBtn": ->
    id = @_id
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
