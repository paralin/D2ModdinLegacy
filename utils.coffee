@findUserLobby = (userId)->
  lobbies.findOne
    $or: [{creatorid: userId}, {"radiant._id": userId}, {"dire._id": userId}]
    status: {$lt: 2}
