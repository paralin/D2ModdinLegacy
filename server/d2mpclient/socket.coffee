Fiber = Npm.require('fibers')
ws = Meteor.require('ws').Server
clientVersion = "0.5.8"

clientSockets = {}
@setMod = (client, mod)->
  sockid = clients.findOne {steamIDs: client.services.steam.id}
  return if !sockid?
  sock = clientSockets[sockid._id]
  return if !sock?
  sock.send "setmod:#{mod}"
@dspectate = (client, addr)->
  sockid = clients.findOne {steamIDs: client.services.steam.id}
  return if !sockid?
  sock = clientSockets[sockid._id]
  return if !sock?
  log.info "#{client._id} -> spectate #{addr}"
  sock.send "dspectate:#{addr}"
@launchDota = (client)->
  sockid = clients.findOne {steamIDs: client.services.steam.id}
  return if !sockid?
  sock = clientSockets[sockid._id]
  return if !sock?
  sock.send "launchdota"
@dconnect = (client, addr)->
  sockid = clients.findOne {steamIDs: client.services.steam.id}
  return if !sockid?
  sock = clientSockets[sockid._id]
  return if !sock?
  log.info "#{client._id} -> dconnect #{addr}"
  sock.send "dconnect:#{addr}"
@installMod = (client, mod)->
  sock = clientSockets[client._id]
  return false if !sock?
  command = "installmod:"+mod.name+"="+mod.version+":"+generateModDownloadURL(mod)
  log.info "#{client._id} -> install #{mod.name}"
  sock.send command
  return true
@shutdownClient = (userId)->
  user = Meteor.users.findOne({_id: userId})
  client = clients.findOne({steamIDs: user.services.steam.id})
  return if !user? or !client?
  sock = clientSockets[client._id]
  return if !sock?
  sock.send "close"
  console.log "told client "+client._id+" to shutdown"
@uninstallClient = (userid)->
  user = Meteor.users.findOne({_id: userId})
  client = clients.findOne({steamIDs: user.services.steam.id})
  return if !user? or !client?
  sock = clientSockets[client._id]
  return if !sock?
  sock.send "uninstall"
  console.log "told client "+client._id+" to uninstall"

Meteor.startup ->
  clients.remove({})

Meteor.publish "clientProgram", ->
  if !@userId?
    return []
  user = Meteor.users.findOne({_id: @userId})
  steamID = user.services.steam.id
  clients.find({steamIDs: steamID})
  
checkBannedClient = (ws, clientObj)->
  for sid in clientObj.steamIDs
    user = Meteor.users.findOne {'services.steam.id': sid}
    continue if !user?
    if AuthManager.userIsInRole user._id, "banned"
      log.info "[BANNEDCLIENT] #{user.profile.name} is banned, uninstall client"
      uninstallClient user._id
      return

@clientServer = new ws({port: 3005})
clientServer.on 'connection', (ws)->
  ourID = null
  clientObj =
    steamIDs: []
    installedMods: []
    status: 0
  new Fiber(->
    ourID = clients.insert clientObj
    clientObj._id = ourID
    clientSockets[ourID] = ws
  ).run()
  console.log "new clientEXE connected"
  ws.on 'message', (msg)->
    new Fiber(->
      splitMsg = msg.split ':'
      if splitMsg.length < 2
        return
      switch splitMsg[0]
        when 'init'
          splitMsg[2] = splitMsg[2].replace(/\s+/g, '')
          if splitMsg[2] != clientVersion
            clientObj.status = 1
            console.log "wrong version #{splitMsg[2]} != #{clientVersion}"
          for steamID in splitMsg[1].split(',')
            steamID = steamID.replace(/\D/g,'')
            if steamID.length != 17
              #ws.send 'invalidid'
              return
            #console.log "client steamID: "+steamID
            if clientObj.steamIDs.indexOf(steamID) is -1
              clientObj.steamIDs.push(steamID)
          clientObj.installedMods = splitMsg[3].split ","
          clients.update {_id: ourID}, clientObj
          checkBannedClient ws, clientObj
        when 'installedMod'
          modname = splitMsg[1]
          mod = mods.findOne({name: modname})
          if !mod?
            console.log "client installed unknown mod: "+modname
            return
          modname += "="+mod.version
          toRemove = []
          for modn in clientObj.installedMods
            if modn.split("=")[0] is mod.name
              toRemove.push(modn)
          toRemove.unshift clientObj.installedMods
          clientObj.installedMods = _.without.apply(_, toRemove)
          console.log "client installed "+modname
          clientObj.installedMods.push(modname)
          console.log "  -> mods: "+clientObj.installedMods
          clients.update {_id: ourID}, clientObj
    ).run()
  ws.on 'close', ->
    console.log "client disconnected"
    new Fiber(->
      clients.remove {_id: ourID}
      delete clientSockets[ourID]
    ).run()
