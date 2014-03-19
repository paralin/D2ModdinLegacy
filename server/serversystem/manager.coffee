
#Note this class cannot yet horizontally scale
Fiber = Npm.require('fibers')
ws = Meteor.require('ws').Server
serverPassword = "mHCYLzo7SAcpIcxXCmlR"

idCounter=100

sockets = {}

servers = new Meteor.Collection "servers"
Meteor.startup ->
  servers.remove({})
  lobbyQueue.find().observeChanges
    added: (id, fields)->
      queueProc()
  servers.find().observeChanges
    added: (id, fields)->
      queueProc()

launchServer = (serv, lobby)->
  id = idCounter
  idCounter+=1
  port = Math.floor(Math.random()*1000)+27000
  serv.activeLobbies.push
    id: id
    port: port
    lobby: lobby
  servers.update {_id: serv._id}, {$set: {activeLobbies: serv.activeLobbies}}
  lobbies.update {_id: lobby}, {$set: {status: 2, serverIP: serv.ip+":"+port}}
  theLob = lobbies.findOne({_id: lobby})
  launchCmd = "launchServer|"+id+"|"+port+"|"+(if theLob.devMode then "True" else "False")+"|"+theLob.mod
  sockets[serv._id].send launchCmd
  console.log "server launched, id: "+id
  console.log "   -> "+launchCmd

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
          lobbies.update {_id: sess.lobby}, {$set: {$status: 3}}
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
        when "onShutdown"
          serverObj = servers.findOne({_id: ourID})
          sessId = parseInt(splitMsg[1])
          lobIdx = _.findWhere serverObj.activeLobbies, {id: sessId}
          return if !lobIdx?
          console.log "game session ended "+splitMsg[1]
          sess = serverObj.activeLobbies.splice lobIdx, 1
          sess = sess[0]
          lobbies.update {_id: sess.lobby}, {$set: {status: 3}}
          servers.update {_id: ourID}, {$set: {activeLobbies: serverObj.activeLobbies}}
          queueProc()
    ).run()
