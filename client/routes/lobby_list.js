Router.map(function () {
  this.route("lobbyList", {
    path: "lobbies/:name?",
    template: "lobbyList",
    data: function(){
      if(this.params.name != undefined)
      {
        var mod = mods.findOne(); 
        if(mod == null || !mod.playable){
          if(mod != null && !mod.playable){
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
        return {hasMod: true, mod: mod._id, lobbies: lobbyList.find({mod: mod._id}), modD: mod};
      }
      return {lobbies: lobbyList.find()};
    }
  });
});
