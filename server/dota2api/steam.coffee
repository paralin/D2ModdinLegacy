@d2API = null
Meteor.startup ->
  d2API = new Dota2("A3EA0B2EBBB5835F450EBABC2287C937")
@getIdentityByUser = (userId)->
  user = Meteor.users.findOne({_id: userId})
  return Steam.getIdentity(user.services.steam.id)
