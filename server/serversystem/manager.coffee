Fiber = Npm.require('fibers')
ws = Meteor.require('ws').Server
serverPassword = "mHCYLzo7SAcpIcxXCmlR"

servers = new Meteor.Collection "servers"
Meteor.startup ->
  servers.remove({})

@hostServer = new ws({port: 3006})
hostServer.on 'connection', (ws)->
  serverObj =
    maxPlayers: 0
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
          serverObj.maxPlayers = parseInt(splitMsg[2])
          serverObj.ip = ws.upgradeReq.connection.remoteAddress
          console.log "new server init "+serverObj.ip+" max players "+serverObj.maxPlayers
          ourID = servers.insert serverObj
        when "onShutdown"
          sessId = parseInt(splitMsg[1])
          lobIdx = _.findWhere serverObj.activeLobbies, {id: sessId}
          return if !lobIdx?
          console.log "game session ended "+splitMsg[1]
          sess = serverObj.activeLobbies.splice lobIdx, 1
          lobbies.update {_id: sess.lobby}, {$set: {status: 3}}
    ).run()
