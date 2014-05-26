Fiber = Npm.require('fibers')
ws = Meteor.require('ws').Server

queueOperation = (client, command)->
  sockid = clients.findOne({steamIDs: client.services.steam.id}, {fields: {_id: 1}})
  return if !sockid?
  sockid = sockid._id
  CMsgQueue.insert {id: sockid, msg: command}
@setMod = (client, mod)->
  queueOperation client, "setmod:#{mod}"
@dspectate = (client, addr)->
  queueOperation client, "dspectate:#{addr}"
@launchDota = (client)->
  queueOperation client, "launchdota"
@dconnect = (client, addr)->
  queueOperation client, "dconnect:#{addr}"
@installMod = (client, mod)->
  queueOperation client, "installmod:"+mod.name+"="+mod.version+":"+generateModDownloadURL(mod)

Meteor.publish "clientProgram", ->
  if !@userId?
    @stop()
  user = Meteor.users.findOne({_id: @userId})
  steamID = user.services.steam.id
  clients.find({steamIDs: steamID})
