Router.map(function () {
  this.route("modlist", {
    path: "/mods",
    fastRender: true,
    template: "modlist",
    data: function(){
      return {
        mods: mods.find()
      };
    }
  });
});
