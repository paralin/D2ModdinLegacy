Meteor.publish "adminData", ->
  if !checkAdmin @userId
    @stop()
    return
  user = Meteor.users.findOneFaster {_id: @userId}
  res = []
  res.push servers.findFaster()
  res.push lobbies.findFaster()
  res.push ServerAddons.findFaster()
  res
