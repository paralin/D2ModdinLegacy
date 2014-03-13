Template.lobbyList.events
  "click .joinBtn": ->
    Meteor.call "joinLobby", @_id, (err, res)->
      console.log err if err?
      console.log res if res?
      Meteor.subscribe "lobbyDetails"
  "click .createLobbyBtn": ->
    $.pnotify
      title: "Creating lobby..."
      text: "Requesting a new lobby..."
      type: "info"
      delay: 500
      closer: false
      sticker: false
    Meteor.call "createLobby", (err, res)->
      if err?
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
