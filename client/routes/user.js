Router.map(function () {
  this.route("user", {
    path: "/user",
    template: "user",
    data: function(){
      if(Meteor.user() == undefined){
        this.redirect("/");
        $.pnotify({
          title: "Log In",
          type: "error",
          text: "You must be logged in to see your user info.",
          sticker: false,
          closer: false,
          delay: 1000
        });
      }
      return Meteor.user();
    }
  });
});
