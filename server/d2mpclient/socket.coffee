Fiber = Npm.require('fibers')
ws = Meteor.require('ws').Server
clientVersion = "0.0.7"

Meteor.startup ->
  clients.remove({})

Meteor.publish "clientProgram", ->
  if !@userId?
    return clients.find({secretproperty: "yupnothappening"})
  user = Meteor.users.findOne({_id: @userId})
  clients.find({steamID: user.services.steam.id})

@clientServer = new ws({port: 3005})
clientServer.on 'connection', (ws)->
  ourID = null
  clientObj =
    steamID: null
    installedMods: []
    status: 0
  new Fiber(->
    ourID = clients.insert clientObj
    clientObj._id = ourID
  ).run()
  console.log "new clientEXE connected"
  ws.on 'message', (msg)->
    splitMsg = msg.split ':'
    # should be 2 parts
    if splitMsg.length < 2
      return
    if splitMsg[0] is 'init'
      steamID = splitMsg[1]
      steamID = steamID.replace(/\D/g,'')
      if steamID.length != 17
        ws.send 'invalidid'
        return
      if splitMsg[2] != clientVersion
        clientObj.status = 1
      console.log "client steamID is "+steamID
      clientObj.steamID = steamID
      new Fiber(()->
        clients.update {_id: ourID}, clientObj
      ).run()
  ws.on 'close', ->
    console.log "client disconnected"
    new Fiber(->
      clients.remove {_id: ourID}
    ).run()
