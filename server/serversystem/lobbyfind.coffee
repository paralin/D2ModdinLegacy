@lobbyQueue = new Meteor.Collection "lobbyQueue"

Meteor.startup ->
  lobbyQueue.remove({})

@cancelFindServer = (lobbyId)->
  lobbyQueue.remove
    _id: lobbyId

@startFindServer = (lobbyId)->
  console.log "finding server for "+lobbyId
  lobby = lobbies.findOne {_id: lobbyId}
  return if !lobby?
  lobbyQueue.insert
    _id: lobbyId
    started: new Date().getTime()
    region: lobby.region
  lobbies.update {_id: lobbyId}, {$set: {status: 1}}
