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
        modSub = Meteor.subscribe("modThumbList");
      }
      return [Meteor.subscribe("lobbyList"), modSub];
    },
    data: function(){
      if(this.params.name != undefined)
      {
        var mod = mods.findOne(); 
        if(mod == null || !mod.playable){
          if(!mod.playable){
            $.pnotify({
              title: "Not Available",
              text: "This mod is not ready to be played yet.",
              type: "error",
              delay: 1000
            });
          }
          Router.go("/lobbies");
          return;
        }
        return {hasMod: true, mod: this.params.name, lobbies: lobbies.find({mod: this.params.name}), modD: mods.findOne({name: this.params.name})};
      }
      return {lobbies: lobbies.find()};
    }
  });
});
