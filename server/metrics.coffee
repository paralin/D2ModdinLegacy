Meteor.publish "metrics", ->
  Metrics.find()
Meteor.startup ->
  if !Metrics.findOne({_id: 'login'})?
    Metrics.insert {_id: 'login', enabled: true}
  Metrics.remove({_id: "ausers"})
  Metrics.insert
    _id: "ausers"
    count: 0
  cursor = Meteor.users.find({'status.online': true}, {fields: {_id: 1}})
  updateAUsers = ->
    Metrics.update {_id: "ausers"}, {$set: {count: cursor.count()}}
  cursor.observeChanges
    added: updateAUsers
    removed: updateAUsers
  updateAUsers()
Meteor.methods
  "toggleSignups": ->
    if !@userId?
      throw new Meteor.Error 403, "You are not signed in."
    if !AuthManager.userIsInRole @userId, "admin"
      throw new Meteor.Error 403, "You are not an admin."
    metric = Metrics.findOne {_id: "login"}
    metric.enabled = !metric.enabled
    Metrics.update {_id: "login"}, {$set: {enabled: metric.enabled}}
    "New signups are now #{if metric.enabled then "enabled" else "disabled"}."
