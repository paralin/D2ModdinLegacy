Meteor.startup(function(){
  Deps.autorun(function(){
    var route = Router.current();
    if(route == null) return;
    if(route.route.name != "lobby")
    Meteor.call("leaveLobby");
  });
});
chatStream = null;
Router.map(function () {
  this.route("lobby", {
    path: "/lobby/:id",
    template: "lobby",
    loginRequired: {
      name: 'loggingIn',
      shouldRoute: false
    },
    unload: function(){
      if(chatStream != null)
      {
        chatStream.close();
        chatStream = null;
        Session.set("chatStream", null);
      }
    },
    load: function(){
      Meteor.subscribe("lobbyDetails"); //make sure this is done
      //Get chat stream
      chatStream = new Meteor.Stream(this.params.id); 
      console.log(chatStream)
      Session.set("chatStream",chatStream);
      //check if already in lobby
      var lobby = lobbies.findOne({status: {$ne: null}}, {reactive: false});
      if(lobby == null){
        console.log("Joining lobby "+this.params.id);
        Meteor.call("joinLobby", this.params.id, function(err, res){
          if(err != null){
            if(err.error==401){
              console.log("Mod files not installed, redirecting");
              Session.set("requestedLobby", this.params.id);
              Router.go("/install/"+err.reason);
              return;
            }
            console.log("error joining: "+err.reason);
            Router.go(Router.routes["lobbyList"].path());
            $.pnotify({
              title: "Can't Join Lobby",
              text: err.reason,
              type: "error",
              delay: 5000,
              closer: false,
              sticker: false
            });
          }else{
            console.log("joined lobby");
            $.pnotify({title:"Joined Lobby", text: "Welcome to the lobby.", type: "success", delay: 1500, closer: false, sticker: false})
          }
        });
      }
    }
  });
});
