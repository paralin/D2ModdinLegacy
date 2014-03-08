api = null
Meteor.startup ->
  api = new Dota2("A3EA0B2EBBB5835F450EBABC2287C937")
Meteor.methods
  getIdentity: ()->
    console.log "getIdentity"
    if !@userId?
      throw new Meteor.Error 403, "You must be logged in"
    user = Meteor.users.findOne({_id: @userId})
    return Steam.getIdentity(user.services.steam.id)
  getMatches: ()->
    if !@userId?
      throw new Meteor.Error 403, "You must be logged in"

    return api.matchHistory({})
