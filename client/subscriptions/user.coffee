Meteor.startup ->
  Deps.autorun ->
    user = Meteor.user()
    return if !user?
    Meteor.subscribe("userData")
