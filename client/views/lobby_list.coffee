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
      callMethod "createlobby", {name: null, mod: @mod}
