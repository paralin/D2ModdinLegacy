Template.lobbyList.thisMod = ->
  mods.findOne {_id: @mod}
Template.lobbyList.events
  "click .enterLobPass": ->
    bootbox.prompt
      title: "What is the lobby password (case sensitive)?"
      callback: (res)->
        return if !res?
        Meteor.call "joinPassLobby", res, (err, res)->
          if err?
            if err.error is 401
              Router.go "/install/"+err.reason
              return
            $.pnotify
              title: "Can't Join Lobby"
              text: err.reason
              type: "error"
  "click .joinBtn": ->
    Meteor.call "joinLobby", @_id, (err, res)->
      if err?
        if err.error is 401
          Router.go "/install/"+err.reason
          return
        $.pnotify
          title: "Can't Join Lobby"
          type: "error"
          text: err.reason
          delay: 5000
          sticker: false
  "click .createLobbyBtn": ->
    if !@mod?
      Router.go Router.routes["createLobby"].path()
    else
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
