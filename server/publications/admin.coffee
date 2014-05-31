Meteor.publish "adminData", ->
  if !checkAdmin @userId
    @stop()
    return
  user = Meteor.users.findOne {_id: @userId}
  res = []
  res.push servers.find()
  res.push lobbies.find()
  res.push ServerAddons.find()
  res
