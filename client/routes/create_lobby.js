Router.map(function () {
  this.route("createLobby", {
    path: "newlobby",
    fastRender: true,
    template: "createLobby",
    waitOn: function(){
      return Meteor.subscribe("modThumbList");
    },
    loginRequired: {
      name: 'loggingIn',
      shouldRoute: false
    },
    data: function(){
      return {mods: mods.find()}
    }
  });
});
