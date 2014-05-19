common =
  before: ->
    this.redirect("/") if (!Meteor.loggingIn() && !Meteor.user()) || !AuthManager.userIsInRole(Meteor.userId(), "admin")
  waitOn: ->
    Meteor.subscribe("adminData")
admin =
  path: "/admin"
  template: "admin"
adminServer =
  path: "/admin/server/:id"
  template: "adminServer"
  data: ->
    serv = servers.findOne({_id: @params.id})
    if !serv?
      @redirect "/admin"
      return
    serv
users =
  path: "/users"
  template: "userList"

Router.map ->
  @route "admin", _.extend admin, common
  @route "adminServer", _.extend adminServer, common
  @route "users", _.extend users, common
