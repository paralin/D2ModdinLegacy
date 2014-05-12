Meteor.startup ->
  Metrics.remove({_id: "matches"})
  cursor = MatchResults.find({}, {fields: {_id: 1}})
  Metrics.insert({_id: "matches", count: cursor.count()})
  updateCount = ->
    Metrics.update {_id: "matches"}, {$set: {count: cursor.count()}}
  cursor.observeChanges
    added:updateCount
    removed:updateCount
