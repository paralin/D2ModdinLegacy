ws = Meteor.require('ws').Server

@clientServer = new ws({port: 3005})
clientServer.on 'connection', (ws)->
  client =
  {
  }
