Router.map(function () {
  this.route("lobbyList", {
    path: "lobbies/:name?",
    template: "lobbyList",
    waitOn: function(){
      return Meteor.subscribe("lobbyList");
    },
    data: function(){
      return {lobbies: lobbies.find()};
    }
  });
});
