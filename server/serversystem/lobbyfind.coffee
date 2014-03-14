@lobbyQueue = new Meteor.Collection "lobbyQueue"

Meteor.startup ->
  lobbyQueue.remove({})

@cancelFindServer = (lobbyId)->
  console.log "canceling server search: "+lobbyId

@startFindServer = (lobbyId)->
  console.log "finding server for "+lobbyId
  lobbyQueue.insert
    lobby: lobbyId
    started: new Date().getTime()


@kickPlayer = (steamId)->
  console.log "removing player from server "+steamId
