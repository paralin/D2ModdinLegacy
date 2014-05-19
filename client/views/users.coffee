Template.userList.users = ->
  Meteor.users.find()
Template.userList.events
  "click .delBtn": ->
    return if !confirm "Are you sure you want to delete #{@profile.name}?"
    Meteor.call "deleteUser", @_id, showNiceNot
