Router.map ->
  @route "admin",
    path: "/admin"
    template: "admin",
    loginRequired:
      name: "loggingIn",
      shouldRoute: false
    before: ->
      this.redirect("/") if !Meteor.loggingIn() && !Meteor.user()
    waitOn: ->
      Meteor.subscribe("adminData")
