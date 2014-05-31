Meteor.publish "lobbyList", ->
  lobbies.find
    public: true
    isMatchmaking: false
    status: {$lt: 1}
    hasPassword: false
  ,
    fields:
      name: 1
      mod: 1
      creator: 1
      radiant:1
      dire:1
      region: 1

Meteor.publish "lobbyDetails", ->
  user = Meteor.users.findOne {_id: @userId}
  if !user? || !user.lobbyID?
    return []
  lobbies.find
    _id: user.lobbyID
  ,
    limit: 1
    fields:
      name: 1
      mod: 1
      creator: 1
      isMatchmaking: 1
      invitedPlayers: 1
      serverIP: 1
      status: 1
      requiresFullLobby: 1
      creatorid: 1
      region: 1
      radiant: 1
      dire: 1
      state: 1
      spectator: 1
      spectatorEnabled: 1
