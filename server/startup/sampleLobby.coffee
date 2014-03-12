###
#Fill the DB with hard-coded lobby
###

Meteor.startup ->
  if lobbies.find().count() is 0
    lobbies.insert
      name: "Test Lobby"
      hasPassword: false
      creator: "Quantum"
      radiant: []
      isMatchmaking: false
      mod: "fof"
      dire: []
      invitedPlayers: []
      serverIP: ""
      mmid: null
      public: true
      status: 0
      requiresFullLobby: false
      serverStatus: 0
      devMode: true
