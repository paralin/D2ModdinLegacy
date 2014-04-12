Meteor.publish "adminData", ->
  if !AuthManager.userIsInRole @userId, "admin"
    @stop()
    return
  user = Meteor.users.findOne {_id: @userId}
  res = []

  #Send out the server list
  res.push servers.find()
  res.push lobbies.find({status: {$ne: 4}})
  res.push mods.find()
  res.push ServerAddons.find()
  res
