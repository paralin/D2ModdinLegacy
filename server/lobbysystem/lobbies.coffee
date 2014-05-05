
#Not yet horizontally scalable (see disconnectTimeouts)
disconnectTimeouts = {}
#Monitor user events
Meteor.startup ->
  #Delete temporary lobbies (not finished)
  lobbies.remove {status: {$lt: 4}}
  Meteor.users.find({"status.online": false}).observeChanges
    removed: (id)->
      timeout = disconnectTimeouts[id]
      if timeout?
        Meteor.clearTimeout(timeout)
        delete disconnectTimeouts[id]
    added: (id, fields)->
      #Schedule leave lobby
      disconnectTimeouts[id] = Meteor.setTimeout ->
        leaveLobby(id)
        shutdownClient(id)
      , 30000

setPlayerTeam = (lobby, uid, tteam)->
  return if !lobby?
  index = _.findWhere(lobby.radiant, {_id: uid})
  team = "radiant"
  if !index?
    index = _.findWhere(lobby.dire, {_id: uid})
    team = "dire"
  return if tteam is team
  if index?
    index = lobby[team].indexOf(index)
    lobby[tteam].push(lobby[team].splice(index, 1)[0])
    lobbies.update {_id: lobby._id},
      $set:
        radiant: lobby.radiant
        dire: lobby.dire

@checkIfDeleteLobby = (lobbyId)->
  lobby = lobbies.find({_id: lobbyId})
  return if !lobby?
  return if lobby.status is 2 or lobby.status is 3
  if !(_.contains(lobby.radiant, lobby.creatorid)) && !(_.contains(lobby.dire, lobby.creatorid))
    if lobby.status < 4
      #Game never started
      lobbies.remove({_id: lobbyId})

internalRemoveFromLobby = (userId, lobby)->
  index = _.findWhere(lobby.radiant, {_id: userId})
  team = null
  if index?
    team = "radiant"
  else
    index = _.findWhere(lobby.dire, {_id: userId})
    team = "dire"
  if index?
    updateObj = {}
    lobby[team].splice(index, 1)
    updateObj[team] = lobby[team]
    lobbies.update {_id: lobby._id},
      $set: updateObj
  if lobby.creatorid is userId and lobby.status < 2
    lobbies.remove({_id: lobby._id})

@leaveInProgressLobby = (userId)->
  return if !userId?
  user = Meteor.users.findOne({_id: userId})
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
  user = Meteor.users.findOne({_id: userId})
  return if !user?
  lobby = findUserLobby(userId)
  return lobby?

maybeStopMatchmaking = (userId, l)->
  if l.status is 1 or l.status is 2
    console.log l._id+" cancel server search b/c user left"
    lobbies.update {_id: l._id}, {$set: {status: 0}}
    cancelFindServer l._id

@leaveLobby = (userId)->
  lobby = lobbies.find
    $or: [{creatorid: userId}, {"radiant._id": userId}, {"dire._id": userId}]
    status: {$lt: 3}
  lobby.forEach (l)->
    internalRemoveFromLobby(userId, l)
    maybeStopMatchmaking(userId, l)
    stopFinding(l)
    console.log userId+" left lobby "+l._id

startGame = (lobby)->
  startFindServer lobby._id
  lobbies.update({_id: lobby._id}, {$set: {status: 1}})

@createLobby = (creatorId, mod, name)->
  return if !creatorId?
  console.log creatorId+" created lobby"
  user = Meteor.users.findOne({_id: creatorId})
  setMod user, mod.name
  return lobbies.insert
    name: name
    hasPassword: false
    creator: user.profile.name
    creatorid: creatorId
    radiant: [{_id: creatorId, name: user.profile.name, avatar: user.services.steam.avatar, steam: user.services.steam.id}]
    dire: []
    isMatchmaking: false
    mod: mod.name
    invitedPlayers: []
    serverIP: ""
    mmid: null
    public: true
    status: 0
    requiresFullLobby: false
    devMode: false
    enableGG: true

@joinLobby = (lobby, userId)->
  #Check if already in 
  return if userId is lobby.creatorid
  return if (_.findWhere(lobby.dire, {_id: userId}))?
  return if (_.findWhere(lobby.radiant, {_id: userId}))?
  user = Meteor.users.findOne({_id: userId})
  team = null
  if lobby.dire.length >= lobby.radiant.length && lobby.dire.length < 5
    team = "dire"
  else
    team = "radiant"
  lobby[team].push
    _id: userId
    name: user.profile.name
    avatar: user.services.steam.avatar
    steam: user.services.steam.id
  console.log userId+" joined lobby "+lobby.name
  updateObj  = {}
  updateObj[team] = lobby[team]
  lobbies.update {_id: lobby._id}, {$set: updateObj}
  setMod user, lobby.mod

stopFinding = (lobby)->
  return if lobby.status != 1 && lobby.status != 2
  cancelFindServer lobby._id
  lobbies.update {_id: lobby._id}, {$set: {status: 0}}

Meteor.methods
  "stopFinding": ->
    if !@userId?
      throw new Meteor.Error 404, "Not finding a match."
    lobby = lobbies.findOne({creatorid: @userId})
    if !lobby?
      throw new Meteor.Error 403, "Not the owner of this lobby."
    stopFinding(lobby)
  "startGame": ->
    if !@userId?
      throw new Meteor.Error 403, "Log in first."
    lobby = lobbies.findOne({creatorid: @userId, status: {$ne: 4}})
    if !lobby?
      throw new Meteor.Error 404, "You are not the host of a lobby."
    if lobby.status isnt 0
      throw new Meteor.Error 403, "Lobby has already been started."
    if lobby.requiresFullLobby and (lobby.dire.length+lobby.radiant.length) isnt 10
      throw new Meteor.Error 403, "Lobby must be full to start."
    startGame(lobby)
  "setLobbyName": (name)->
    check(name, String)
    if !@userId?
      throw new Meteor.Error 403, "You're not even logged in, come on, try harder."
    lobby = lobbies.findOne({creatorid: @userId, status: {$lt: 4}})
    if !lobby?
      throw new Meteor.Error 403, "You don't own any lobbies."
    if name.length > 40
      name = name.substring 0, 40
    #name = name.replace(/\W+/g, " ")
    lobbies.update {_id: lobby._id}, {$set: {name: name}}
  "joinLobby": (id)->
    if !@userId?
      throw new Meteor.Error 403, "You must be logged in to join a lobby."
    lobby = lobbies.findOne
      _id: id
      status: 0
      hasPassword: false
    if !lobby?
      throw new Meteor.Error 404, "Can't find that lobby."
    if (lobby.dire.length+lobby.radiant.length) is 10
      throw new Meteor.Error 404, "Lobby is full."
    if lobby.isMatchmaking
      throw new Meteor.Error 403, "Can't join a matchmaking lobby directly."
    mod = mods.findOne({name: lobby.mod})
    if !mod?
      throw new Meteor.Error 404, "Can't seem to find the mod in the database."
    if mod.bundlepath?
      user = Meteor.users.findOne({_id: @userId})
      client = clients.findOne({steamIDs: user.services.steam.id})
      if !client? || !_.contains(client.installedMods, lobby.mod+"="+mod.version)
        console.log "mod install needed: "
        console.log "  -> client = "+JSON.stringify client
        console.log "  -> mod needed = "+lobby.mod+"="+mod.version
        throw new Meteor.Error 401, lobby.mod
    joinLobby lobby, @userId
    console.log @userId+" joined lobby "+lobby.name
  "leaveLobby": ->
    return if !@userId?
    leaveLobby(@userId)
  "createLobby": (mod, name) ->
    if !@userId?
      throw new Meteor.Error 403, "You must be logged in to make a lobby."
    user = Meteor.users.findOne({_id: @userId})
    leaveLobby(@userId)
    if isIngame(@userId)
      throw new Meteor.Error 403, "You are already in a game."
    if !name?
      name = user.profile.name+"'s Lobby"
    mod = mods.findOne({name: mod})
    if mod.bundlepath?
      #Find their client
      user = Meteor.users.findOne({_id: @userId})
      client = clients.findOne({steamIDs: user.services.steam.id})
      if !client? || !_.contains(client.installedMods, mod.name+"="+mod.version)
        throw new Meteor.Error 401, mod.name
    return createLobby(@userId, mod, name)
  "switchTeam": (team)->
    return if !@userId?
    lobby = findUserLobby(@userId)
    return if !lobby?
    setPlayerTeam lobby, @userId, team
