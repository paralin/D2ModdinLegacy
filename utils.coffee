@findUserLobby = (userId)->
  return if !userId?
  user = Meteor.users.findOne {_id: userId}
  return if !user? || !user.lobbyID?
  lobbies.findOne {_id: user.lobbyID}

#finds a player in (lobby) with (id)
#returns [team(0,1), obj]
@locatePlayer = (lobby, uid)->
  return if !lobby?
  index = null
  for plyr in lobby.radiant
    continue if !plyr? || !plyr._id?
    if plyr._id is uid
      index = plyr
      break
  team = "radiant"
  if !index?
    for plyr in lobby.dire
      continue if !plyr? || !plyr._id?
      if plyr._id is uid
        index = plyr
        break
    team = "dire"
  ###if !index?
    ix = -1
    for slot in lobby.spectator
      ix++
      index = _.findWhere(slot, {_id: uid})
      team = "spectator"+ix
      break if index?
  ###
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
