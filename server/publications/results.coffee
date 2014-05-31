Meteor.publish "matchResult", (id)->
  MatchResults.find {_id: id},
    fields:
      spectate_addr: 0
      match_id: 0
      num_players: 0
