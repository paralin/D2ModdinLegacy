Meteor.autorun ->
  user = Meteor.userId()
  return if !user?
  Meteor.subscribe "clientProgram"
