Meteor.startup ->
  MatchResults.remove({$or: [{$where: "this.teams[0].players.length < 2"}, {$where: "this.teams[1].players.length < 2"}, {status: {$ne: "completed"}}]})
  lobbies.remove {status: {$lt: 4}}
