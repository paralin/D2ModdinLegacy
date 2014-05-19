Meteor.methods
  "deleteUser": (id)->
    if !@userId? || !AuthManager.userIsInRole(@userId, "admin")
      throw new Meteor.Error 403, "You are not authorized to delete users."
    delu = Meteor.users.findOne {_id: id}
    if !delu?
      throw new Meteor.Error 404, "Can't find that user."
    leaveLobby id
    Meteor.users.remove {_id: delu._id}
    "The user #{delu.profile.name} has been deleted."
