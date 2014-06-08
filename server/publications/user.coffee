Meteor.publish "userData", ->
  if !@userId?
    return @stop()
  Meteor.users.find {_id: @userId}, {limit: 1, fields: {
    services: 1
  }}
