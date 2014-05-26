@findUserLobby = (userId)->
  lobbies.findOne
    uids: userId
    status: {$lt: 4}
#finds a player in (lobby) with (id)
#returns [team(0,1), obj]
@locatePlayer = (lobby, uid)->
  return if !lobby?
  index = _.findWhere(lobby.radiant, {_id: uid})
  team = "radiant"
  if !index?
    index = _.findWhere(lobby.dire, {_id: uid})
    team = "dire"
  if !index?
    ix = -1
    for slot in lobby.spectator
      ix++
      index = _.findWhere(slot, {_id: uid})
      team = "spectator"+ix
      break if index?
  [team, index]
@locatePlayerS = (lobby, uid)->
  return if !lobby?
  index = _.findWhere(lobby.radiant, {steam: uid})
  team = "radiant"
  if !index?
    index = _.findWhere(lobby.dire, {steam: uid})
    team = "dire"
  if !index?
    ix = -1
    for slot in lobby.spectator
      ix++
      index = _.findWhere(slot, {steam: uid})
      team = "spectator"+ix
      break if index?
  [team, index]
