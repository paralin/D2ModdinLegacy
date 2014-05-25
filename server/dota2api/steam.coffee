@getIdentityByUser = (userId)->
  user = Meteor.users.findOne({_id: userId})
  return Steam.getIdentity(user.services.steam.id)
