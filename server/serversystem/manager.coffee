
#Note this class cannot yet horizontally scale
Fiber = Npm.require('fibers')
Rcon = Meteor.require('srcds-rcon')
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

configureServer = (serverObj, lobby, instance)->
  console.log "configuring server "+instance.ip+":"+instance.port
  srvr = newRcon instance.ip+":"+instance.port, instance.rconPass
  Async.runSync (done)->
    srvr.connect ->
      for plyr in lobby.radiant
        Async.runSync (done2)->
          srvr.runCommand "add_radiant_player "+plyr.steam+" "+plyr.name, done2
      for plyr in lobby.dire
        Async.runSync (done2)->
          srvr.runCommand "add_dire_player "+plyr.steam+" "+plyr.name, done2
      done()
  console.log "server configured"
  finalizeInstance(serverObj, lobby)

launchServer = (serv, lobby)->
  id = idCounter
  idCounter+=1
  port = Math.floor(Math.random()*1000)+27000
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

finalizeInstance = (serv, lobby)->
  lobbies.update {_id: lobby}, {$set: {status: 3, serverIP: serv.ip+":"+port}}

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

@hostServer = new ws({port: 3006})
hostServer.on 'connection', (ws)->
  serverObj =
    maxLobbies: 0
    activeLobbies: []
    ip: ""
  ourID = null
  console.log "new server connected"
  ws.on 'close', ->
    new Fiber(->
      if ourID?
        for sess in serverObj.activeLobbies
          lobbies.update {_id: sess.lobby}, {$set: {$status: 4}}
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
          console.log "new server init "+serverObj.ip+" max lobbies "+serverObj.maxLobbies
          ourID = servers.insert serverObj
          sockets[ourID] = ws
        when "serverLaunched"
          serverObj = servers.findOne({_id: ourID})
          sessId = parseInt(splitMsg[1])
          pendInstance = pendingInstances.findOne {id: sessId}
          lobby = lobbies.findOne {_id: pendInstance.lobby}
          lobbies.remove {_id: pendInstance.lobby}
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
