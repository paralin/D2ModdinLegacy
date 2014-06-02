Meteor.startup ->
  Deps.autorun ->
    Meteor.user()
    Meteor.subscribe("userData")
