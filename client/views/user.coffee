getIdentity = ->
  console.log "get identity"
  Meteor.call "getIdentity", (err, data)->
    if err?
      $.pnotify
        title: "Error"
        text: err.reason
        type: "error"
    if data?
      Session.set("identity", data)
      console.log data

Template.user.identity = ()->
  Session.get("identity")

Template.user.events
  "click .refreshBtn": getIdentity
Meteor.startup ->
  getIdentity()
