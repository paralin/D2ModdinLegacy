
#Note this class cannot yet horizontally scale
Fiber = Npm.require('fibers')
Rcon = Meteor.require('rcon')
ws = Meteor.require('ws').Server
serverPassword = "mHCYLzo7SAcpIcxXCmlR"

idCounter=100

sockets = {}

servers = new Meteor.Collection "servers"
pendingInstances = new Meteor.Collection "pendingInstances"
Meteor.startup ->
  servers.remove({})
  pendingInstances.remove({})
  lobbyQueue.find().observeChanges
    added: (id, fields)->
      queueProc()
  servers.find().observeChanges
    added: (id, fields)->
      queueProc()

#versions looks like rota=0.1,lobby=0.5
getAddonInstalls = (versions)->
  toinst = []
  currAddons = {}
  for ver in versions
    p = ver.split '='
    currAddons[p[0]] = p[1]
  console.log currAddons
  #check against server versions
  for addon in ServerAddons.find().fetch()
    curr = currAddons[addon.name]
    if !curr? || curr isnt addon.version
      toinst.push(addon.name+"="+addon.version+"="+getBundleDownloadURL(addon.bundle).split('=').join('+'))
  toinst.join ','

configureServer = (serverObj, lobby, instance)->
  console.log "configuring server "+instance.ip+":"+instance.port
  srvr = new Rcon instance.ip, instance.port, instance.rconPass, {challenge:false}
  connecting = true
  srvr.connect()
  srvr.on('auth', ->
    connecting = false
    srvr.send "log 1;"
    srvr.send "sm plugins load addxp;"
    srvr.send "update_addon_paths;"
    srvr.send "dota_local_custom_enable 1;"
    srvr.send "dota_local_custom_game "+lobby.mod+";"
    srvr.send "dota_local_custom_map "+lobby.mod+";"
    for plyr in lobby.radiant
      cmd = "add_radiant_player "+plyr.steam+" \""+plyr.name+"\""
      #cmd = "add_radiant_player "+plyr.steam+" \"RadiantPlayer\";"
      srvr.send cmd
      console.log cmd
    for plyr in lobby.dire
      cmd = "add_dire_player "+plyr.steam+" \""+plyr.name+"\""
      #cmd = "add_dire_player "+plyr.steam+" \"DirePlayer\";"
      srvr.send cmd
      console.log cmd
    srvr.send "dota_force_gamemode 15;"
    srvr.send "map "+lobby.mod+";"
    console.log "server configured"
    new Fiber(->
      Meteor.setTimeout(->
        finalizeInstance(serverObj, lobby, instance)
      , 10000)
    ).run()
  ).on('response', (str)->
    console.log "rcon resp: "+str
  ).on('end', ->
    console.log "rcon disconnected for "+instance.id
    if connecting
      console.log "configuring server failed!!!"
      handleFailConfigure serverObj, lobby, instance
  ).on 'error', (err)->
    if err.errno is 'ETIMEDOUT'
      console.log "RCON failed connection to server "+instance.ip+":"+instance.port
      handleFailConfigure serverObj, lobby, instance

launchServer = (serv, lobby)->
  id = idCounter
  idCounter+=1
  port = Math.floor(Math.random()*1000)+30000
  rconPass = Random.id()
  serv.activeLobbies.push
    id: id
    port: port
    lobby: lobby
    started: new Date().getTime()
    rconPass: rconPass
  theLob = lobbies.findOne({_id: lobby})
  servers.update {_id: serv._id}, {$set: {activeLobbies: serv.activeLobbies}}
  lobbies.update {_id: lobby}, {$set: {status: 2, serverIP: serv.ip+":"+port}}
  sockets[serv._id].send "launchServer|"+id+"|"+port+"|"+(if theLob.devMode then "True" else "False")+"|"+theLob.mod+"|"+rconPass
  pendingInstances.insert
    id: id
    port: port
    ip: serv.ip
    lobby: lobby
    rconPass: rconPass
    started: new Date().getTime()
  console.log "server launched, id: "+id+" waiting for configure"

handleFailConfigure = (serv, lobby, instance)->
  console.log "failed to configure server, re-queuing lobby and disabling server"
  removeServerFromPool serv._id
  pendingInstances.remove {id: instance.id}
  lobbyQueue.remove {lobby: lobby._id}
  startFindServer lobby._id

finalizeInstance = (serv, lobby, instance)->
  lobbies.update {_id: lobby._id}, {$set: {status: 3, serverIP: serv.ip+":"+instance.port}}
  pendingInstances.remove {id: instance.id}

queueProc = ->
  #Find elegible servers
  nextGame = lobbyQueue.findOne({}, {started: 1})
  return if !nextGame?
  servs = servers.find().fetch()
  maxLobbies = 9999999999
  chosen = null
  for serv in servs
    if serv.activeLobbies.length < maxLobbies && serv.activeLobbies.length<maxLobbies
      chosen = serv
      maxLobbies = serv.activeLobbies
  return if !chosen?
  launchServer(chosen, nextGame.lobby)
  lobbyQueue.remove({_id: nextGame._id})

removeServerFromPool = (id)->
  serv = servers.findOne {_id: id}
  return if !serv?
  console.log "removing server "+id+" ("+serv.ip+") from pool due to failure"
  servers.update {_id: id}, {$set: {enabled: false}}

@hostServer = new ws({port: 3006})
hostServer.on 'connection', (ws)->
  serverObj =
    maxLobbies: 0
    activeLobbies: []
    ip: ""
    enabled: true
  ourID = null
  console.log "new server connected"
  ws.on 'close', ->
    new Fiber(->
      if ourID?
        for sess in serverObj.activeLobbies
          lobbies.update {_id: sess.lobby}, {$set: {status: 4}}
        servers.remove({_id: ourID})
    ).run()
    delete sockets[ourID]
    console.log "host disconnected "+serverObj.ip
  ws.on 'message', (msg)->
    new Fiber(->
      splitMsg = msg.split "|"
      return if splitMsg.length < 2
      switch splitMsg[0]
        when "init"
          if splitMsg[1] isnt serverPassword
            ws.send 'authFail'
            return
          serverObj.maxLobbies = parseInt(splitMsg[2])
          serverObj.ip = ws.upgradeReq.connection.remoteAddress
          versions = splitMsg[3].split ','
          installStr = getAddonInstalls(versions)
          if installStr is ""
            console.log "new server init "+serverObj.ip
            ourID = servers.insert serverObj
            sockets[ourID] = ws
          else
            #console.log "told server to install "+installStr
            ws.send 'installAddons|'+installStr
        when "serverLaunched"
          serverObj = servers.findOne({_id: ourID})
          sessId = parseInt(splitMsg[1])
          pendInstance = pendingInstances.findOne {id: sessId}
          lobby = lobbies.findOne {_id: pendInstance.lobby}
          lobbyQueue.remove {lobby: pendInstance.lobby}
          configureServer serverObj, lobby, pendInstance
        when "onShutdown"
          serverObj = servers.findOne({_id: ourID})
          sessId = parseInt(splitMsg[1])
          lobIdx = _.findWhere serverObj.activeLobbies, {id: sessId}
          return if !lobIdx?
          console.log "game session ended "+splitMsg[1]
          sess = serverObj.activeLobbies.splice lobIdx, 1
          sess = sess[0]
          lobbies.update {_id: sess.lobby}, {$set: {status: 4}}
          servers.update {_id: ourID}, {$set: {activeLobbies: serverObj.activeLobbies}}
          queueProc()
    ).run()
