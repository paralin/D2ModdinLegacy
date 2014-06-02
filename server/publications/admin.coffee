Meteor.publish "adminData", ->
  if !checkAdmin @userId
    @stop()
    return
  res = [Meteor.users.find({}, {fields: {authItems: 1, profile: 1, services: 1}})]
  res
