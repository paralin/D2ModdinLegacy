@findUserLobby = (userId)->
  lobbies.findOne
    $or: [{creatorid: userId}, {"radiant._id": userId}, {"dire._id": userId}]
    status: {$lt: 4}
#finds a player in (lobby) with (id)
#returns [team(0,1), obj]
@locatePlayer = (lobby, id)->
  #search dire
  team = 1
  obj = _.findWhere lobby.dire, {steam: id}
  if !obj?
    team = 0
    obj = _.findWhere lobby.radiant, {steam: id}
  [team, obj]
