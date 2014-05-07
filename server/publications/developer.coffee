Meteor.publish "devData", ->
  if !@userId? || !AuthManager.userIsInRole(@userId, "developer")
    return @stop()
  [modfetch.find({user: @userId}), mods.find(user: @userId)]
