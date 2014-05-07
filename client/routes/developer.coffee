common =
  before: ->
    this.redirect("/") if (!Meteor.loggingIn() && !Meteor.user()) || !AuthManager.userIsInRole(Meteor.userId(), "developer")
  waitOn: ->
    Meteor.subscribe("devData")
developer =
  path: "/developer"
  template: "developer"
newFetch =
  path: '/developer/newfetch'
  template: "newFetch"
fetchDetail =
  path: '/developer/fetches/:id'
  template: 'fetchDetail'
  data: ->
    data = modfetch.findOne({_id: @params.id})
    if !data?
      @redirect Router.routes["developer"].path()
      return
    data
Router.map ->
  @route "developer", _.extend developer, common
  @route "newFetch", _.extend newFetch, common
  @route "fetchDetail", _.extend fetchDetail, common
