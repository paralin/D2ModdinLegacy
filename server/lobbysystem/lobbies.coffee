Array::clean = (deleteValue) ->
  i = 0
  while i < @length
    if this[i] is deleteValue
      @splice i, 1
      i--
    i++
  this
#Not yet horizontally scalable (see disconnectTimeouts)
disconnectTimeouts = {}
disconnectLTimeouts = {}
#Monitor user events
Meteor.startup ->
  Meteor.users.findFaster({"status.online": false}).observeChanges
    removed: (id)->
      timeout = disconnectLTimeouts[id]
      if timeout?
        Meteor.clearTimeout(timeout)
        delete disconnectLTimeouts[id]
      timeout = disconnectTimeouts[id]
      if timeout?
        Meteor.clearTimeout(timeout)
        delete disconnectTimeouts[id]
    added: (id, fields)->
      #Schedule leave lobby
      disconnectLTimeouts[id] = Meteor.setTimeout ->
        leaveLobby(id)
      , 5000
      disconnectTimeouts[id] = Meteor.setTimeout ->
        shutdownClient(id)
      , 60000
 
updatePlayer = (lobby, id, props)->
  [team, player] = locatePlayerS lobby, id
  if !player?
    log.error "Can't findFaster player in #{lobby._id} to update"
    return
  _.extend player, props
  lobbies.update {_id: lobby._id}, {$set: {radiant: lobby.radiant, dire: lobby.dire}}
  lobby

locateRPlayer = (result, id)->
  #search dire
  team = -1
  player = null
  for te in result.teams
    team++
    for pla in te.players
      if pla.account_id is id
        player = pla
        break
    break if player?
  [team, player]

updateRPlayer = (result, id, props)->
  [team, player] = locateRPlayer result, id
  if !player?
    #log.error "Can't findFaster player #{id} in #{result._id} to update"
    return
  _.extend player, props
  MatchResults.update {_id: result._id}, {$set: {teams: result.teams}}
  result

@handleEvent = (id, eve)->
  lobby = lobbies.findOneFaster {_id: id}
  result = MatchResults.findOneFaster {_id: id} 
  return if !lobby? || !result?
  if eve.player?
    eve.player = toSteamID64 eve.player
  switch eve.event_type
    when EVENTS.GameStateChange
      states = GAMESTATEK[eve.new_state]
      log.info "#{id} state is now #{states}"
      lobby.state = eve.new_state
      lobbies.update {_id: id}, {$set: {state: lobby.state}}
      result = MatchResults.findOneFaster {_id: id}
      if result?
        status = "loading"
        if eve.new_state > GAMESTATE.HeroSelect && eve.new_state < GAMESTATE.PostGame
          status = "playing"
        else if eve.new_state > GAMESTATE.Playing
          status = "ending"
        MatchResults.update {_id: id}, {$set: {status: status}}
    when EVENTS.PlayerConnect
      log.info "[EVENT] #{eve.player} connected"
      lobby = updatePlayer lobby, eve.player, connected: true
      result = updateRPlayer result, eve.player, connected:true
    when EVENTS.PlayerDisconnect
      log.info "[EVENT] #{eve.player} disconnected"
      if lobby.state > GAMESTATE.WaitLoad
        lobby = updatePlayer lobby, eve.player, connected: false
        result = updateRPlayer result, eve.player, connected:false
    when EVENTS.HeroDeath
      [team, player] = locateRPlayer result, eve.player
      if player?
        player.deaths++
      for killer in eve.killers
        killer = toSteamID64 killer
        [team, killd] = locateRPlayer result, killer
        if killd?
          killd.kills++
      MatchResults.update {_id: id}, {$set: {teams: result.teams}}
@handleMatchComplete = (id, data)->
  lobby = lobbies.findOneFaster {_id: id}
  result = MatchResults.findOneFaster {_id: id}
  for team in data.teams
    for player in team.players
      player.account_id = toSteamID64 player.account_id
      [tid, lplay] = locatePlayer lobby, player.account_id
      if !lplay?
        log.error "Can't findFaster player #{player.account_id} to update name & avatar"
        return
      log.debug JSON.stringify lplay
      player.avatar = lplay.avatar.full
      player.name = lplay.name
  data.status = "completed"
  if result?
    MatchResults.update {_id: id}, {$set: data, $unset: {spectate_addr: ""}}
  if lobby?
    lobbies.remove {_id: id}
@handleLoadFail = (id)->
  lobby = lobbies.findOneFaster {_id: id}
  return if !MatchResults.findOneFaster({_id: id})?
  MatchResults.remove {_id: id}
  log.info "[LOADFAIL] Players failed to load for #{id}"
  if lobby?
    for player in lobby.radiant
      if !player.connected?
        player.connected = false
      if !player.connected
        log.info " -X- #{player.name}"
    for player in lobby.dire
      if !player.connected?
        player.connected = false
      if !player.connected
        log.info " -X- #{player.name}"
    lobbies.update {_id: id}, {$set: {status: 0, state: GAMESTATE.Init, radiant:lobby.radiant, dire:lobby.dire}}

getPlayerTeam = (uid, lobby)->
  [team, index] = locatePlayer lobby, uid
  [index, team]

removeFromTeam = (uid, lobby)->
  [index, team] = getPlayerTeam uid, lobby
  return if !index?
  if team is "radiant" or team is "dire"
    index = lobby[team].indexOf(index)
    res = lobby[team].splice(index, 1)[0]
    return res
  else
    specIdx = parseInt team.substring(9)
    res = lobby.spectator[specIdx].splice(index, 1)[0]
    return res

setPlayerTeam = (lobby, uid, tteam)->
  return if !lobby?
  res = removeFromTeam uid, lobby
  if tteam is "radiant" or tteam is "dire"
    lobby[tteam].push(res)
  else
    lobby.spectator[parseInt(tteam.substring(9))].push res
  lobbies.update {_id: lobby._id}, {$set: {radiant: lobby.radiant, dire: lobby.dire, spectator: lobby.spectator}}

@checkIfDeleteLobby = (lobbyId)->
  lobby = lobbies.findOneFaster({_id: lobbyId})
  return if !lobby?
  return if lobby.status is 2 or lobby.status is 3
  if !(_.contains(lobby.radiant, lobby.creatorid)) && !(_.contains(lobby.dire, lobby.creatorid))
    lobbies.remove({_id: lobbyId}) if lobby.status < 4

internalRemoveFromLobby = (userId, lobby)->
  Meteor.users.update {_id: userId}, {$unset: {lobbyID: ""}}, {multi: true}
  if (lobby.creatorid is userId and lobby.status < 2) or (lobby.dire.length+lobby.radiant.length)<2
    lobbies.remove({_id: lobby._id})
    return
  lobby.radiant.clean(null);
  lobby.dire.clean(null);
  teams = [lobby.radiant, lobby.dire]
  player = null
  for tea in teams
    for plyr in tea
      continue if !plyr? || !plyr._id
      if plyr._id is userId
        player = plyr
        break
    if player?
      tea.splice tea.indexOf(player), 1
      break
  if !player?
    log.error "Can't find player #{userId} in lobby #{lobby._id} to remove"
    return
  lobbies.update {_id: lobby._id}, {$set: {radiant: lobby.radiant, dire: lobby.dire}}

@leaveInProgressLobby = (userId)->
  return if !userId?
  user = Meteor.users.findOneFaster({_id: userId})
  return if !user?
  lobby = findUserLobby(userId)
  if lobby.isMatchmaking
    console.log "user abandoned matchmaking game: "+userId
    #Various peanalties here
  kickPlayer(user.services.steam.id)
  internalRemoveFromLobby(userId, lobby)
  console.log "user removed from lobby in progress "+userId

isIngame = (userId)->
  return if !userId?
  user = Meteor.users.findOneFaster({_id: userId})
  return if !user?
  lobby = findUserLobby(userId)
  return lobby?

maybeStopMatchmaking = (userId, l)->
  if l.status is 1 or l.status is 2
    console.log l._id+" cancel server search b/c user left"
    lobbies.update {_id: l._id}, {$set: {status: 0}}
    cancelFindServer l._id

@kickPlayer = (lobbyId, userId)->
  l = lobbies.findOne {_id: lobbyId}
  return if !l?
  internalRemoveFromLobby(userId, l)
  stopFinding(l)
  if !l.banned?
    l.banned = [userId]
  else
    l.banned.push userId
  lobbies.update {_id: l._id}, {$set: {banned: l.banned}}
  console.log userId+" banned from lobby "+lobbyId

@leaveLobby = (userId)->
  user = Meteor.users.findOne {_id: userId}, {fields: {lobbyID: 1}}
  return if !user? || !user.lobbyID?
  l = lobbies.findOne {_id: user.lobbyID}
  if !l?
    Meteor.users.update {_id: userId}, {$unset: {lobbyID: ""}}
    return
  internalRemoveFromLobby(userId, l)
  stopFinding(l)

startGame = (lobby)->
  startFindServer lobby._id
  for player in lobby.radiant
    player.connected = undefined
  for player in lobby.dire
    player.connected = undefined
  lobbies.update({_id: lobby._id}, {$set: {status: 1, radiant: lobby.radiant, dire: lobby.dire}})

@createLobby = (creatorId, mod, name)->
  return if !creatorId?
  user = Meteor.users.findOneFaster({_id: creatorId})
  log.info "[Lobby] #{mod.name} - #{user.profile.name}"
  setMod user, mod.name+"="+mod.version
  return lobbies.insert
    name: name
    hasPassword: false
    password: ""
    banned: []
    creator: user.profile.name
    creatorid: creatorId
    radiant: [{_id: creatorId, name: user.profile.name, avatar: user.services.steam.avatar, steam: user.services.steam.id}]
    dire: []
    spectator: [[], []]
    spectatorEnabled: AuthManager.userIsInRole creatorId, ["admin", "developer", "moderator"]
    isMatchmaking: false
    mod: mod.name
    serverIP: ""
    mmid: null
    public: true
    status: 0
    region: 0
    requiresFullLobby: !(AuthManager.userIsInRole(creatorId, ["admin", "developer", "moderator"]))
    devMode: false
    enableGG: true
    state: GAMESTATE.Init

@joinLobby = (lobby, userId)->
  return if !lobby? || !userId?
  return if lobby.status > 0
  user = Meteor.users.findOneFaster {_id: userId}
  return if user.lobbyID?
  team = null
  if lobby.dire.length <= lobby.radiant.length && lobby.dire.length < 5
    team = "dire"
  else
    team = "radiant"
  lobby[team].push
    _id: userId
    name: user.profile.name
    avatar: user.services.steam.avatar
    steam: user.services.steam.id
  lobby[team].clean(null);
  updateObj  = {}
  updateObj[team] = lobby[team]
  lobbies.update {_id: lobby._id}, {$set: updateObj}
  mod = mods.findOneFaster {name: lobby.mod}
  setMod user, lobby.mod+"="+mod.version
  Meteor.users.update {_id: userId}, {$set: {lobbyID: lobby._id}}

stopFinding = (lobby)->
  return if !lobby? || lobby.status > 1
  cancelFindServer lobby._id
  lobbies.update {_id: lobby._id}, {$set: {status: 0}}

Meteor.methods
  "devCreateLobby": (fetchid) ->
    if !@userId? || !AuthManager.userIsInRole @userId, "developer"
      throw new Meteor.Error 403, "Not authorized."
    fetch = modfetch.findOneFaster {_id: fetchid}
    if !fetch?
      throw new Meteor.Error 404, "Can't findFaster that fetch."
    mod = mods.findOneFaster {fetch: fetchid}
    if !mod?
      throw new Meteor.Error 404, "Can't findFaster the mod."
    user = Meteor.users.findOneFaster {_id: @userId}
    client = clients.findOneFaster({steamIDs: user.services.steam.id})
    if !client? || !_.contains(client.installedMods, mod.name+"="+mod.version)
      throw new Meteor.Error 401, mod.name
    createLobby @userId, mod, "Test Lobby"
  "stopFinding": ->
    if !@userId?
      throw new Meteor.Error 404, "Not finding a match."
    lobby = lobbies.findOneFaster({creatorid: @userId})
    if !lobby?
      throw new Meteor.Error 403, "Not the owner of this lobby."
    console.log "stop finding #{lobby._id}"
    stopFinding(lobby)
  "startGame": ->
    if !@userId?
      throw new Meteor.Error 403, "Log in first."
    lobby = lobbies.findOneFaster({creatorid: @userId})
    if !lobby?
      throw new Meteor.Error 404, "You are not the host of a lobby."
    if lobby.status isnt 0
      throw new Meteor.Error 403, "Lobby has already been started."
    if lobby.requiresFullLobby and (lobby.dire.length+lobby.radiant.length) isnt 10
      throw new Meteor.Error 403, "Lobby must be full to start."
    startGame(lobby)
  "setLobbyPassword": (pass)->
    check pass, String
    if !@userId?
      throw new Meteor.Error 403, "You're not even logged in, come on, try harder."
    lobby = lobbies.findOneFaster({creatorid: @userId})
    if !lobby?
      throw new Meteor.Error 403, "You don't own any lobbies."
    if pass.length > 40
      pass = pass.substring 0, 40
    lobbies.update({_id: lobby._id}, {$set: {hasPassword: pass.length isnt 0, password: pass}})
  "setLobbyRegion": (region)->
    check region, Number
    if !@userId?
      throw new Meteor.Error 403, "You're not even logged in, come on, try harder."
    lobby = lobbies.findOneFaster({creatorid: @userId})
    if !lobby?
      throw new Meteor.Error 403, "You don't own any lobbies."
    reg = REGIONSK[region]
    if !reg?
      throw new Meteor.Error 404, "Can't findFaster that region."
    lobbies.update {_id: lobby._id}, {$set: {region: region}}
  "setLobbyName": (name)->
    check(name, String)
    if !@userId?
      throw new Meteor.Error 403, "You're not even logged in, come on, try harder."
    lobby = lobbies.findOneFaster({creatorid: @userId})
    if !lobby?
      throw new Meteor.Error 403, "You don't own any lobbies."
    if name.length > 40
      name = name.substring 0, 40
    lobbies.update {_id: lobby._id}, {$set: {name: name}}
  "joinPassLobby": (pass)->
    check pass, String
    if !@userId?
      throw new Meteor.Error 403, "You must be logged in to join a lobby."
    if AuthManager.userIsInRole @userId, "banned"
      throw new Meteor.Error 403 ,"You are banned from joining/creating lobbies."
    exist = findUserLobby @userId
    if exist?
      throw new Meteor.Error 403, "You are already in a lobby."
    lobby = lobbies.findOne
      status: 0
      hasPassword: true
      password: pass
    if !lobby?
      throw new Meteor.Error 404, "Can't findFaster a waiting lobby with that pass."
    if (lobby.dire.length+lobby.radiant.length) is 10
      throw new Meteor.Error 404, "Lobby is full."
    if lobby.isMatchmaking
      throw new Meteor.Error 403, "Can't join a matchmaking lobby directly."
    mod = mods.findOneFaster({name: lobby.mod})
    if !mod?
      throw new Meteor.Error 404, "Can't seem to findFaster the mod in the database."
    if mod.bundle?
      client = clients.findOne({_id: @userId})
      if !client? || !_.contains(client.installedMods, lobby.mod+"="+mod.version)
        throw new Meteor.Error 401, lobby.mod
    if _.contains lobby.banned, @userId
      throw new Meteor.Error 403, "You have been kicked from this lobby."
    joinLobby lobby, @userId
    console.log @userId+" joined passworded lobby "+lobby.name
  "joinLobby": (id)->
    check id, String
    if !@userId?
      throw new Meteor.Error 403, "You must be logged in to join a lobby."
    if AuthManager.userIsInRole @userId, "banned"
      throw new Meteor.Error 403 ,"You are banned from joining/creating lobbies."
    exist = findUserLobby @userId
    if exist?
      throw new Meteor.Error 403, "You are already in a lobby."
    lobby = lobbies.findOne
      _id: id
      status: 0
      hasPassword: false
    if !lobby?
      throw new Meteor.Error 404, "Can't findFaster that lobby."
    if (lobby.dire.length+lobby.radiant.length) >= 10
      throw new Meteor.Error 404, "Lobby is full."
    if lobby.isMatchmaking
      throw new Meteor.Error 403, "Can't join a matchmaking lobby directly."
    mod = mods.findOneFaster({name: lobby.mod})
    if !mod?
      throw new Meteor.Error 404, "Can't seem to findFaster the mod in the database."
    if mod.bundle?
      client = clients.findOne({_id: @userId})
      if !client? || !_.contains(client.installedMods, lobby.mod+"="+mod.version)
        throw new Meteor.Error 401, lobby.mod
    if _.contains lobby.banned, @userId
      throw new Meteor.Error 403, "You have been kicked from this lobby."
    joinLobby lobby, @userId
    console.log @userId+" joined lobby "+lobby.name
  "kickPlayer": (id)->
    check(id, String)
    user = Meteor.users.findOneFaster({_id: @userId})
    if !@userId?
      throw new Meteor.Error 403, "You're not even logged in, come on, try harder."
    lobby = lobbies.findOneFaster({creatorid: @userId})
    if !lobby?
      throw new Meteor.Error 403, "You don't own any lobbies."
    kickPlayer(lobby._id, id)
    leaveLobby(id)
  "leaveLobby": ->
    return if !@userId?
    leaveLobby(@userId)
  "createLobby": (mod, name) ->
    if !@userId?
      throw new Meteor.Error 403, "You must be logged in to make a lobby."
    if AuthManager.userIsInRole @userId, "banned"
      throw new Meteor.Error 403 ,"You are banned from joining/creating lobbies."
    user = Meteor.users.findOneFaster({_id: @userId})
    leaveLobby(@userId)
    if isIngame(@userId)
      throw new Meteor.Error 403, "You are already in a game."
    if !name?
      name = user.profile.name+"'s Lobby"
    if name.length > 40
      name = name.substring 0, 40
    mod = mods.findOneFaster({name: mod})
    if !mod?
      throw new Meteor.Error 404, "Can't findFaster the mod you want in the db."
    if !mod.playable
      throw new Meteor.Error 403, "This mod is not playable yet."
    if mod.bundle?
      #Find their client
      client = clients.findOneFaster({_id: @userId})
      if !client? || !_.contains(client.installedMods, mod.name+"="+mod.version)
        throw new Meteor.Error 401, mod.name
    lobby = createLobby(@userId, mod, name)
    Meteor.users.update {_id: @userId}, {$set: {lobbyID: lobby}}
    lobby
  "joinBroadcaster": (slot)->
    return if !@userId?
    lobby = findUserLobby(@userId)
    return if !lobby?
    if !lobby.spectatorEnabled
      throw new Meteor.Error 503, "Spectators are not enabled in this lobby."
    if slot >= lobby.spectator.length
      throw new Meteor.Error 503, "That spectator slot doesn't exist."
    setPlayerTeam lobby, @userId, "spectator"+slot
  "switchTeam": (team)->
    return if !@userId?
    lobby = findUserLobby(@userId)
    return if !lobby?
    setPlayerTeam lobby, @userId, team
