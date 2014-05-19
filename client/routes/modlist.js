Router.map(function () {
  this.route("modlist", {
    path: "/mods",
    fastRender: true,
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
