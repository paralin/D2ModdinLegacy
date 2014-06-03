modDetailsSub = null
@chatStream = {}
Router.map ->
  @.route "lobby",
    path: "/lobby/:id",
    template: "lobby",
