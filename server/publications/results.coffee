#todo: add uid,name to players
Meteor.publish "resultList",(skip, opts)->
  skip = 1 if !skip?
  skip--
  skip *= 10
  qopts = {
    sort: {date: -1}
    skip: skip
    limit: 10
    fields:
      date:1
      good_guys_win:1
      status: 1
      mod: 1
      teams: 1
      match_id: 1
  }
  delete qopts["skip"] if skip < 1
  MatchResults.find {}, qopts
Meteor.publish "matchResult", (id)->
  MatchResults.find {_id: id}
