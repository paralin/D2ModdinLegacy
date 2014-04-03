modDetailsSub = null
Meteor.startup ->
  Deps.autorun ->
    route = Router.current()
    return if(route == null)
    if(route.route.name != "lobby")
      Meteor.call("leaveLobby")
@chatStream = {}
Router.map ->
  @.route "lobby",
    path: "/lobby/:id",
    template: "lobby",
    loginRequired:
      name: 'loggingIn',
      shouldRoute: false
    waitOn: ->
      Meteor.subscribe("modDetailsForLobby")
    load:->
      Meteor.subscribe("lobbyDetails")
      #Get chat stream
      if !chatStream[@params.id]?
        chatStream[@params.id] = new Meteor.Stream(@.params.id)
      #check if already in lobby
      lobby = lobbies.findOne({status: {$ne: null}}, {reactive: false})
      if(lobby == null)
        console.log "Joining lobby "+@.params.id
        Meteor.call "joinLobby", @.params.id, (err, res)->
          if err != null
            if err.error is 401
              console.log("Mod files not installed, redirecting")
              Session.set("requestedLobby", @.params.id)
              Router.go("/install/"+err.reason)
              return
            console.log("error joining: "+err.reason)
            Router.go(Router.routes["lobbyList"].path())
            $.pnotify
              title: "Can't Join Lobby",
              text: err.reason,
              type: "error",
              delay: 5000,
              closer: false,
              sticker: false
          else
            $.pnotify({title:"Joined Lobby", text: "Welcome to the lobby.", type: "success", delay: 1500, closer: false, sticker: false})
