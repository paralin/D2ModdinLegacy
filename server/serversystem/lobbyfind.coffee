@lobbyQueue = new Meteor.Collection "lobbyQueue"

Meteor.startup ->
  lobbyQueue.remove({})

@cancelFindServer = (lobbyId)->
  console.log "canceling server search: "+lobbyId
  lobbyQueue.remove
    lobby: lobbyId

@startFindServer = (lobbyId)->
  console.log "finding server for "+lobbyId
  lobbyQueue.insert
    lobby: lobbyId
    started: new Date().getTime()
  lobbies.update {_id: lobbyId}, {$set: {status: 1}}
