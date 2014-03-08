Meteor.methods
  getIdentity: ()->
    console.log "getIdentity"
    if !@userId?
      throw new Meteor.Error 403, "You must be logged in"
    user = Meteor.users.findOne({_id: @userId})
    return Steam.getIdentity(user.services.steam.id)
