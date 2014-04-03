Router.map(function () {
  this.route("createLobby", {
    path: "newlobby",
    template: "createLobby",
    waitOn: function(){
      return Meteor.subscribe("modList");
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
