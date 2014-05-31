Meteor.publish "adminData", ->
  if !checkAdmin @userId
    @stop()
    return
  user = Meteor.users.findOneFaster {_id: @userId}
  res = []
  res.push servers.findFaster()
  res.push lobbies.findFaster()
  res.push ServerAddons.findFaster()
  res.push users.findFaster({}, {fields: {authItems: 1, profile: 1, services: 1}})
  res
