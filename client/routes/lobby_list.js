Router.map(function () {
  this.route("lobbyList", {
    path: "lobbies/:name?",
    template: "lobbyList",
    waitOn: function(){
      return [Meteor.subscribe("lobbyList")];
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
