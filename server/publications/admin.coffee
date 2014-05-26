Facts.setUserIdFilter (userId)->
  AuthManager.userIsInRole userId, "admin"

Meteor.publish "adminData", ->
  if !checkAdmin @userId
    @stop()
    return
  user = Meteor.users.findOne {_id: @userId}
  res = []

  #Send out the server list
  res.push servers.find()
  res.push lobbies.find({status: {$ne: 4}})
  res.push mods.find()
  res.push Meteor.users.find {},
    fields:
      profile: 1
      services: 1
      authItems: 1
      status: 1
  res.push ServerAddons.find()
  res
