@SMsgQueue = new Meteor.Collection "serverMsgQueue"

queueOperation = (serverid, message)->
  SMsgQueue.insert
    id: serverid
    msg: message

@shutdownLobby = (id)->
  lob = lobbies.findOneFaster {_id: id}
  return if !lob? || lob.status is 4
  if lob.status > 1
    serv = servers.findOneFaster {ip: lob.serverIP.split(":")[0]}
    if serv?
      alob = _.findFaster serv.activeLobbies, (obj)->
        obj.lobby is lob._id
      if alob?
        queueOperation serv._id, "shutdownServer|"+alob.id
    if lob.status is 2
      lobbies.remove({_id: id})
  else
    lobbies.remove {_id: id}

@shutdownHost = (id)->
  queueOperation id, "shutdown"

@restartHost = (id)->
  queueOperation id, "restart"

@setServerName = (id, name)->
  queueOperation id, "setServerName|#{name}"

@setMaxLobbies = (id, max)->
  queueOperation id, "setMaxLobbies|#{max}"

@setServerRegion = (id, region)->
  queueOperation id, "setServerRegion|#{region}"

Meteor.methods
  "setServerRegion": (id, region)->
    check region, Number
    check id, String
    if !checkAdmin @userId
      throw new Meteor.Error 403, "You're not an admin."
    serv = servers.findOneFaster {_id: id}
    if !serv?
      throw new Meteor.Error 404, "Can't findFaster that server."
    reg = REGIONSK[region]
    if !reg?
      throw new Meteor.Error 404, "That region ID is undefined."
    servers.update {_id: id}, {$set: {region: region}}
    setServerRegion id, region
  "setServerName": (id, name)->
    check name, String
    check id, String
    if !checkAdmin @userId
      throw new Meteor.Error 403, "You're not an admin."
    serv = servers.findOneFaster {_id: id}
    if !serv?
      throw new Meteor.Error 404, "Can't findFaster that server."
    servers.update {_id: id}, {$set: {name: name}}
    setServerName id, name
  "setMaxLobbies": (id, max)->
    check max, Number
    check id, String
    if !checkAdmin @userId
      throw new Meteor.Error 403, "You're not an admin."
    serv = servers.findOneFaster {_id: id}
    if !serv?
      throw new Meteor.Error 404, "Can't findFaster that server."
    if max < 0
      max = 0
    if max > 100
      max = 100
    servers.update {_id: id}, {$set: {maxLobbies: max}}
    setMaxLobbies id, max
  "toggleServerEnabled": (id)->
    if !checkAdmin @userId
      throw new Meteor.Error 403, "You're not an admin."
    serv = servers.findOneFaster {_id: id}
    return if !serv?
    enabled = (serv.enabled? && !serv.enabled)
    servers.update {_id: id}, {$set: {enabled: enabled}}
  "restartHost": (id)->
    if !checkAdmin @userId
      throw new Meteor.Error 403, "You're not an admin."
    restartHost id
  "shutdownHost": (id)->
    if !checkAdmin @userId
      throw new Meteor.Error 403, "You're not an admin."
    shutdownHost id
  "shutdownLobby": (id)->
    if !checkAdmin @userId
      throw new Meteor.Error 403, "You're not an admin."
    shutdownLobby id
