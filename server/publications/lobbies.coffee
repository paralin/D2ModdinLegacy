
#General mod info for the list
Meteor.publish "lobbyList", ->
  lobbies.find
    public: true
    isMatchmaking: false
  ,
    fields:
      name: 1
      hasPassword: 1
      mod: 1
      creator: 1

Meteor.publish "lobbyDetail", ->
  if !@userId
    return
  lobbies.find
    $or: [{"radiant._id": @userId}, {"dire._id": @userId}]
  ,
    fields:
      name: 1
      mod: 1
      creator: 1
      isMatchmaking: 1
      invitedPlayers: 1
      serverIP: 1
      status: 1
      requiresFullLobby: 1
