Meteor.methods
  "deleteUser": (id)->
    check id, String
    if !@userId? || !AuthManager.userIsInRole(@userId, "admin")
      throw new Meteor.Error 403, "You are not authorized to delete users."
    delu = Meteor.users.findOne {_id: id}
    if !delu?
      throw new Meteor.Error 404, "Can't findFaster that user."
    leaveLobby id
    Meteor.users.remove {_id: delu._id}
    "The user #{delu.profile.name} has been deleted."
  "setBannedUser": (id, banned)->
    check id, String
    if !@userId? || !AuthManager.userIsInRole(@userId, "admin")
      throw new Meteor.Error 403, "You are not authorized to change bans."
    banu = Meteor.users.findOne {_id: id}
    if !banu?
      throw new Meteor.Error 404, "Can't findFaster that user."
    if !banned?
      banned = !AuthManager.userIsInRole id, "banned"
    else
      check banned, Boolean
    if banned
      leaveLobby id
      Meteor.users.update {_id: id}, {$set: {authItems: ["banned"]}}
      uninstallClient id
    else if AuthManager.userIsInRole id, "banned"
      Meteor.users.update {_id: id}, {$unset: {authItems: ""}}
    "The user #{banu.profile.name} has been #{if banned then "banned" else "unbanned"}."
