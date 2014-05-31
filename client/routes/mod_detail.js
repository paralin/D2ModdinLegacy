Router.map(function () {
  this.route("modDetail", {
    path: "/mods/:name",
    template: "modDetail",
    fastRender: true,
    data: function(){
      return {mod: mods.findOne({name: this.params.name})};
    }
  });
});
