Template.lobbyList.events
  "click .joinBtn": ->
    Meteor.call "joinLobby", @_id, (err, res)->
      if err?
        if err.error is 401
          Router.go "/install/"+err.reason
          return
        console.log err
        $.pnotify
          title: "Can't Join Lobby"
          type: "error"
          text: err.reason
          delay: 5000
          sticker: false
      else if !res?
        $.pnotify
          title: "Problem joining lobby"
          type: "error"
          text: "It seems the server somehow failed to put you in the lobby. Try again."
          delay: 5000
          sticker: false
  "click .createLobbyBtn": ->
    if !@mod?
      Router.go Router.routes["createLobby"].path()
    else
      $.pnotify
        title: "Creating lobby..."
        text: "Requesting a new lobby..."
        type: "info"
        delay: 500
        closer: false
        sticker: false
      Meteor.call "createLobby", @mod, (err, res)->
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
