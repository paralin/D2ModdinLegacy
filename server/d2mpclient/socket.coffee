ws = Meteor.require('ws').Server

@clientServer = new ws({port: 3005})
clientServer.on 'connection', (ws)->
  console.log "new clientEXE connected"
  client =
  {
  }
  ws.on 'close', ->
    console.log "client disconnected"
