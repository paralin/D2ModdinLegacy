Router.map(function () {
  this.route("lobbyList", {
    path: "lobbies/:name?",
    template: "lobbyList",
    waitOn: function(){
      var modSub = null;
      if(this.params.name != undefined)
      {
        modSub = Meteor.subscribe("modDetails", this.params.name);
      }else
      {
        modSub = Meteor.subscribe("modList");
      }
      return [Meteor.subscribe("lobbyList"), modSub];
    },
    data: function(){
      if(this.params.name != undefined)
      {
        if(mods.findOne() == null){
          Router.go("/lobbies");
          return;
        }
        return {hasMod: true, mod: this.params.name, lobbies: lobbies.find({mod: this.params.name}), modD: mods.findOne({name: this.params.name})};
      }
      return {lobbies: lobbies.find()};
    }
  });
});
