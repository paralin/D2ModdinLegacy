
#General mod info for the list
Meteor.publish "lobbyList", ->
  lobbies.find
    public: true
    isMatchmaking: false
    status: {$lt: 1}
  ,
    fields:
      name: 1
      hasPassword: 1
      mod: 1
      creator: 1

Meteor.publish "lobbyDetails", ->
  #if !@userId
  #  return
  lobbies.find
    $or: [{"radiant._id": @userId}, {"dire._id": @userId}]
    status: {$ne: 3}
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
      creatorid: 1
      radiant: 1
      dire: 1
