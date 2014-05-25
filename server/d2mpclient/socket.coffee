Fiber = Npm.require('fibers')
ws = Meteor.require('ws').Server

clientSockets = {}
queueOperation = (clientid, message)->
  CMsgQueue.insert
    id: clientid
    msg: message
@setMod = (client, mod)->
  sockid = clients.findOne {steamIDs: client.services.steam.id}
  return if !sockid?
  queueOperation sockid, "setmod:#{mod}"
@dspectate = (client, addr)->
  sockid = clients.findOne {steamIDs: client.services.steam.id}
  return if !sockid?
  queueOperation sockid, "dspectate:#{addr}"
@launchDota = (client)->
  sockid = clients.findOne {steamIDs: client.services.steam.id}
  return if !sockid?
  queueOperation sockid, "launchdota"
@dconnect = (client, addr)->
  sockid = clients.findOne {steamIDs: client.services.steam.id}
  return if !sockid?
  queueOperation sockid, "dconnect:#{addr}"
@installMod = (client, mod)->
  sockid = clients.findOne {steamIDs: client.services.steam.id}
  return if !sockid?
  queueOperation sockid, "installmod:"+mod.name+"="+mod.version+":"+generateModDownloadURL(mod)

processCommand = (id, fields)->
  sock = clientSockets[fields.id]
  return if !sock?
  sock.send fields.msg
  CMsgQueue.remove {_id: id}

Meteor.startup ->
  CMsgQueue.observeChanges
    added: processCommand

Meteor.publish "clientProgram", ->
  if !@userId?
    @stop()
  user = Meteor.users.findOne({_id: @userId})
  steamID = user.services.steam.id
  clients.find({steamIDs: steamID})
  
@clientServer = new ws({port: 3005})
clientServer.on 'connection', (ws)->
  ourID = null
  clientObj =
    steamIDs: []
    installedMods: []
    status: 0
  new Fiber(->
    clientObj.ip = ws.upgradeReq.connection.remoteAddress
    ourID = clients.insert clientObj
    clientObj._id = ourID
    clientSockets[ourID] = ws
    log.info "[Client] Connected, #{clientObj.ip}"
  ).run()
  ws.on 'message', (msg)->
    new Fiber(->
      splitMsg = msg.split ':'
      if splitMsg.length < 2
        return
      switch splitMsg[0]
        when 'init'
          splitMsg[2] = splitMsg[2].replace(/\s+/g, '')
          version = clientParams.findOne({stype: "version"}).version
          if splitMsg[2] != version
            clientObj.status = 1
            console.log "wrong version #{splitMsg[2]} != #{version}"
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
    log.info "[Client] Disconnected #{clientObj.ip}"
    new Fiber(->
      clients.remove {_id: ourID}
      delete clientSockets[ourID]
    ).run()
