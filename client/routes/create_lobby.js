Router.map(function () {
  this.route("createLobby", {
    path: "newlobby",
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
