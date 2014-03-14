Fiber = Npm.require('fibers')
ws = Meteor.require('ws').Server
clientVersion = "0.1.0"

Meteor.startup ->
  clients.remove({})

Meteor.publish "clientProgram", ->
  if !@userId?
    return clients.find({secretproperty: "yupnothappening"})
  user = Meteor.users.findOne({_id: @userId})
  clients.find({steamIDs: user.services.steam.id})

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
  ).run()
  console.log "new clientEXE connected"
  ws.on 'message', (msg)->
    new Fiber(->
      splitMsg = msg.split ':'
      if splitMsg.length < 2
        return

      switch splitMsg[0]

        when 'init'
          if splitMsg[2] != clientVersion
            clientObj.status = 1
          for steamID in splitMsg[1].split(',')
            steamID = steamID.replace(/\D/g,'')
            if steamID.length != 17
              #ws.send 'invalidid'
              return
            console.log "client steamID: "+steamID
            if clientObj.steamIDs.indexOf(steamID) is -1
              clientObj.steamIDs.push(steamID)
          clients.update {_id: ourID}, clientObj

    ).run()
  ws.on 'close', ->
    console.log "client disconnected"
    new Fiber(->
      clients.remove {_id: ourID}
    ).run()
