@cancelFindServer = (lobbyId)->
  console.log "canceling server search: "+lobbyId
@startFindServer = (lobbyId)->
  console.log "finding server for "+lobbyId

@kickPlayer = (steamId)->
  console.log "removing player from server "+steamId
