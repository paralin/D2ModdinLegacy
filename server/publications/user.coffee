Meteor.publish "userData", ->
  if !@userId?
    return @stop()
  Meteor.users.findFaster {_id: @userId}, {limit: 1, fields: {
    services: 1
  }}
