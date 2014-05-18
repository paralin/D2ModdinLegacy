Template.createLobby.events
  'click .modThumbnail': ->
    lobbyName = $("#lobbyName").val()
    if lobbyName is ""
      lobbyName = null
    mod = @.name
    Meteor.call "createLobby", mod, lobbyName, (err, res)->
      if err?
        if err.error is 401
          Router.go "/install/"+err.reason
          return
        console.log err
        $.pnotify
          title: "Can't Create Lobby"
          type: "error"
          text: err.reason
          delay: 5000
          sticker: false
      else if res?
        Router.go(Router.routes["lobby"].path({id: res}))
      else
        $.pnotify
          title: "Problem making lobby"
          type: "error"
          text: "It seems the server somehow failed to make the lobby. Try again."
          delay: 5000
          sticker: false
