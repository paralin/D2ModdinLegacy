Router.map(function () {
  this.route("install", {
    path: "install/:mod",
    load: function(){
      Session.set("isDownMod", false);
    },
    template: "installMod"
  });
});
