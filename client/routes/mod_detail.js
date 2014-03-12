Router.map(function () {
  this.route("modDetail", {
    path: "/mods/:name",
    template: "modDetail",
    waitOn: function(){
      return Meteor.subscribe('modDetails', this.params.name);
    },
    data: function(){
      return {mod: mods.findOne()};
    }
  });
});
