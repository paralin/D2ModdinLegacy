#Monitor user events
Meteor.startup ->
  Meteor.users.find({"status.online": false}).observeChanges
    added: (id, fields)->
      #leaveLobby(id)

@findUserLobby = (userId)->
  lobbies.findOne
    $or: [{creatorid: userId}, {"radiant._id": userId}, {"dire._id": userId}]
    status: {$lt: 2}
setPlayerTeam = (lobby, uid, tteam)->
  return if !lobby?
  index = _.findWhere(lobby.radiant, {_id: uid})
  team = "radiant"
  if !index?
    index = _.findWhere(lobby.dire, {_id: uid})
    team = "dire"
  return if tteam is team
  if index?
    lobby[tteam].push(lobby[team].splice(index, 1)[0])
    lobbies.update {_id: lobby._id},
      $set:
        radiant: lobby.radiant
        dire: lobby.dire

@checkIfDeleteLobby = (lobbyId)->
  lobby = lobbies.find({_id: lobbyId})
  return if !lobby?
  return if lobby.status is 2
  if !(_.contains(lobby.radiant, lobby.creatorid)) && !(_.contains(lobby.dire, lobby.creatorid))
    if lobby.status < 3
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

@leaveLobby = (userId)->
  lobby = lobbies.find
    $or: [{creatorid: userId}, {"radiant._id": userId}, {"dire._id": userId}]
    status: {$lt: 2}
  lobby.forEach (l)->
    internalRemoveFromLobby(userId, l)

@createLobby = (creatorId)->
  return if !creatorId?
  console.log creatorId+" created lobby"
  user = Meteor.users.findOne({_id: creatorId})
  return lobbies.insert
    name: user.profile.name+"'s Lobby"
    hasPassword: false
    creator: user.profile.name
    creatorid: creatorId
    radiant: [{_id: creatorId, name: user.profile.name, avatar: user.services.steam.avatar}]
    dire: []
    isMatchmaking: false
    mod: "fof"
    invitedPlayers: []
    serverIP: ""
    mmid: null
    public: true
    status: 0
    requiresFullLobby: false
    serverStatus: 0
    devMode: true

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
  console.log userId+" joined lobby "+lobby.name
  updateObj  = {}
  updateObj[team] = lobby[team]
  lobbies.update {_id: lobby._id}, {$set: updateObj}

Meteor.methods
  "joinLobby": (id)->
    console.log "joinLobby request " +id
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
    joinLobby lobby, @userId
    console.log @userId+" joined lobby "+lobby.name
  "leaveLobby": ->
    return if !@userId?
    console.log "user leaving lobby "+@userId
    leaveLobby(@userId)
  "createLobby": ->
    if !@userId?
      throw new Meteor.Error 403, "You must be logged in to make a lobby."
    user = Meteor.users.findOne({_id: @userId})
    leaveLobby(@userId)
    if isIngame(@userId)
      throw new Meteor.Error 403, "You are already in a game."
    return createLobby(@userId)
  "switchTeam": (team)->
    return if !@userId?
    lobby = findUserLobby(@userId)
    return if !lobby?
    setPlayerTeam lobby, @userId, team
