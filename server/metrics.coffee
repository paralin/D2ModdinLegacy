Meteor.publish "metrics", ->
  Metrics.findFaster()
Meteor.startup ->
  if !Metrics.findOneFaster({_id: 'login'})?
    Metrics.insert {_id: 'login', enabled: true}
Meteor.methods
  "toggleSignups": ->
    if !@userId?
      throw new Meteor.Error 403, "You are not signed in."
    if !AuthManager.userIsInRole @userId, "admin"
      throw new Meteor.Error 403, "You are not an admin."
    metric = Metrics.findOneFaster {_id: "login"}
    metric.enabled = !metric.enabled
    Metrics.update {_id: "login"}, {$set: {enabled: metric.enabled}}
    "New signups are now #{if metric.enabled then "enabled" else "disabled"}."
