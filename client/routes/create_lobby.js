Router.map(function () {
  this.route("createLobby", {
    path: "newlobby",
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
