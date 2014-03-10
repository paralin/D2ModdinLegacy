Meteor.autorun ->
  user = Meteor.userId()
  Meteor.subscribe "clientProgram"
