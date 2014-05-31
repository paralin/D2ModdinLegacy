Router.map(function () {
  this.route("createLobby", {
    path: "newlobby",
    fastRender: true,
    template: "createLobby",
    loginRequired: {
      name: 'loggingIn',
      shouldRoute: false
    },
    data: function(){
      return {mods: mods.find({playable: true})}
    }
  });
});
