Template.createLobby.events
  'click .modThumbnail': ->
    lobbyName = $("#lobbyName").val()
    if lobbyName is ""
      lobbyName = null
    callMethod "createlobby", {name: lobbyName, mod: @_id}
