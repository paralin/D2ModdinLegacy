Router.map(function () {
  this.route("modDetail", {
    path: "/mods/:name",
    template: "modDetail",
    fastRender: true,
    waitOn: function(){
      return Meteor.subscribe('modDetails', this.params.name);
    },
    data: function(){
      return {mod: mods.findOne({name: this.params.name})};
    }
  });
});
