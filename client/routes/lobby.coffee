modDetailsSub = null
@chatStream = {}
Router.map ->
  @.route "lobby",
    path: "/lobby/:id",
    template: "lobby",
    waitOn: ->
      [Meteor.subscribe("lobbyDetails"), Meteor.subscribe("matchResult", @params.id)]
    action: ->
      lobby = findUserLobby Meteor.userId()
      if !lobby? || lobby._id isnt @params.id
        return @redirect Router.routes["lobbyList"].path()
      @render "lobby"
