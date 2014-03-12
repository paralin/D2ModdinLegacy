Router.map(function () {
  this.route("lobbyList", {
    path: "lobbies/:name?",
    template: "lobbyList",
    waitOn: function(){
      return Meteor.subscribe("lobbyList");
    },
    data: function(){
      if(this.params.name != undefined)
        return {hasMod: true, mod: this.params.name, lobbies: lobbies.find({mod: this.params.name})};
      return {lobbies: lobbies.find()};
    }
  });
});
