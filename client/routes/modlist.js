Router.map(function () {
  this.route("modlist", {
    path: "/mods",
    template: "modlist",
    waitOn: function(){
      return Meteor.subscribe("modList");
    },
    data: function(){
      return {
        mods: mods.find()
      };
    }
  });
});
