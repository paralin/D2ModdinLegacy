Template.createLobby.events
  'click .modThumbnail': ->
    lobbyName = $("#lobbyName").val()
    if lobbyName is ""
      lobbyName = null
    callMethod "createLobby", {name: lobbyName, mod: @_id}
