
#Note this class cannot yet horizontally scale
Fiber = Npm.require('fibers')
ws = Meteor.require('ws').Server
serverPassword = "kwxmMKDcuVjQNutZOwZy"
serverVersion = "1.3.8"
idCounter=100
sockets = {}
pendingInstances = new Meteor.Collection "pendingInstances"

Meteor.startup ->
  sockets = {}
  servers.remove({})
  pendingInstances.remove({})
  Metrics.remove({_id: 'queue'})
  Metrics.insert {_id: 'queue', count: 0}
  cursor = lobbyQueue.find()
  updateLobbyMetric = ->
    Metrics.update {_id: 'queue'}, {$set: {count: cursor.count()}}
  cursor.observeChanges
    added: ->
      queueProc()
      updateLobbyMetric()
    removed: updateLobbyMetric
  servers.find().observeChanges
    added: queueProc
    changed: queueProc
  ServerAddons.find().observeChanges
    _suppress_initial: true
    added: sendReinit
    changed: sendReinit
    removed: sendReinit

sendReinit = _.debounce(->
  for id, socket of sockets
    log.info "re-init #{id}"
    socket.send "reinit"
, 1000)

@shutdownLobby = (id)->
  lob = lobbies.findOne {_id: id}
  return if !lob? || lob.status is 4
  if lob.status > 1
    serv = servers.findOne {ip: lob.serverIP.split(":")[0]}
    if serv?
      alob = _.find serv.activeLobbies, (obj)->
        obj.lobby is lob._id
     if alob?
       sock = sockets[serv._id]
       if sock?
          console.log "told server "+serv._id+" to kill instance "+alob.id
          sock.send "shutdownServer|"+alob.id
    if lob.status is 2
      lobbies.remove({_id: id})
  else
    lobbies.remove {_id: id}
  
@shutdownHost = (id)->
  socket = sockets[id]
  if !socket?
    console.log "host "+id+" told to shut down but no socket found"
    return
  console.log "told host "+id+" to shut down"
  socket.send "shutdown"
@restartHost = (id)->
  socket = sockets[id]
  if !socket?
    console.log "host "+id+" told to restart but no socket found"
    return
  console.log "told host "+id+" to restart"
  socket.send "restart"
@setServerName = (id, name)->
  socket = sockets[id]
  return if !socket?
  log.info "[Server] #{id} set name to #{name}"
  socket.send "setServerName|#{name}"
@setMaxLobbies = (id, max)->
  socket = sockets[id]
  return if !socket?
  log.info "[Server] #{id} set max lobbies to #{max}"
  socket.send "setMaxLobbies|#{max}"
@setServerRegion = (id, region)->
  socket = sockets[id]
  return if !socket?
  log.info "[Server] #{id} set region to #{region}"
  socket.send "setServerRegion|#{region}"

Meteor.methods
  "setServerRegion": (id, region)->
    check region, Number
    check id, String
    if !checkAdmin @userId
      throw new Meteor.Error 403, "You're not an admin."
    serv = servers.findOne {_id: id}
    if !serv?
      throw new Meteor.Error 404, "Can't find that server."
    reg = REGIONSK[region]
    if !reg?
      throw new Meteor.Error 404, "That region ID is undefined."
    servers.update {_id: id}, {$set: {region: region}}
    setServerRegion id, region
  "setServerName": (id, name)->
    check name, String
    check id, String
    if !checkAdmin @userId
      throw new Meteor.Error 403, "You're not an admin."
    serv = servers.findOne {_id: id}
    if !serv?
      throw new Meteor.Error 404, "Can't find that server."
    servers.update {_id: id}, {$set: {name: name}}
    setServerName id, name
  "setMaxLobbies": (id, max)->
    check max, Number
    check id, String
    if !checkAdmin @userId
      throw new Meteor.Error 403, "You're not an admin."
    serv = servers.findOne {_id: id}
    if !serv?
      throw new Meteor.Error 404, "Can't find that server."
    if max < 0
      max = 0
    if max > 100
      max = 100
    servers.update {_id: id}, {$set: {maxLobbies: max}}
    setMaxLobbies id, max
  "toggleServerEnabled": (id)->
    if !checkAdmin @userId
      throw new Meteor.Error 403, "You're not an admin."
    serv = servers.findOne {_id: id}
    return if !serv?
    enabled = (serv.enabled? && !serv.enabled)
    servers.update {_id: id}, {$set: {enabled: enabled}}
  "restartHost": (id)->
    if !checkAdmin @userId
      throw new Meteor.Error 403, "You're not an admin."
    restartHost id
  "shutdownHost": (id)->
    if !checkAdmin @userId
      throw new Meteor.Error 403, "You're not an admin."
    shutdownHost id
  "shutdownLobby": (id)->
    if !checkAdmin @userId
      throw new Meteor.Error 403, "You're not an admin."
    shutdownLobby id

#versions looks:like rota=0.1,lobby=0.5
getAddonInstalls = (versions)->
  toinst = []
  todel = []
  currAddons = {}
  for ver in versions
    p = ver.split '='
    currAddons[p[0]] = p[1]
  #check against server versions
  latestAddons =ServerAddons.find().fetch()
  for addon in latestAddons
    curr = currAddons[addon.name]
    if !curr? || curr isnt addon.version
      toinst.push(addon.name+"="+addon.version+"="+getBundleDownloadURL(addon.bundle).split('=').join('+'))
  for addon, ver of currAddons
    if !ServerAddons.findOne({name: addon})?
      todel.push(addon)
  toinst.join(',')+"|"+todel.join(',')

launchClient = (client)->
  user = Meteor.users.findOne _id: client._id
  return if !user?
  launchDota user

launchClients = (lobby)->
  for client in lobby.radiant
    launchClient client
  for client in lobby.dire
    launchClient client

generateCommands = (lobby)->
  lobby = lobbies.findOne {_id: lobby}
  commands = [
    "d2lobby_gg_time #{(if lobby.enableGG then "5" else "-1")}"
    "match_post_url \"http://d2modd.in/gdataapi/matchres\""
    "set_match_id #{lobby._id}"
  ]
  for plyr in lobby.radiant
    commands.push "add_radiant_player #{plyr.steam} \"#{plyr.name.replace(/\W/g, '')}\""
  for plyr in lobby.dire
    commands.push "add_dire_player #{plyr.steam} \"#{plyr.name.replace(/\W/g, '')}\""
  if lobby.spectatorEnabled
    idx = 0
    for chan in lobby.spectator
      idx++
      continue if chan.length is 0
      cmd = "add_broadcast_channel US \"Broadcast #{idx}\""
      for plyr in chan
        cmd += " #{plyr.steam} \"#{plyr.name.replace(/\W/g, '')}\""
      commands.push cmd
  (commands.join "&").replace /|/g, ''

configureServer = (serverObj, lobby, instance)->
  console.log "bypass rcon configure "+instance.ip+":"+instance.port
  Meteor.setTimeout ->
    finalizeInstance(serverObj, lobby, instance)
  , 8000

launchServer = (serv, lobby)->
  id = idCounter
  idCounter+=1
  while true
    port = Math.floor(Math.random()*(serv.portRangeEnd-serv.portRangeStart))+serv.portRangeStart
    break if !(_.findWhere(serv.activeLobbies, {port: port}))?
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
  mod = mods.findOne {name: theLob.mod}
  sockets[serv._id].send "launchServer|"+id+"|"+port+"|"+(if theLob.devMode then "True" else "False")+"|"+theLob.mod+"="+mod.version+"|"+rconPass+"|"+generateCommands(lobby)
  pendingInstances.insert
    id: id
    port: port
    ip: serv.ip
    lobby: lobby
    rconPass: rconPass
    started: new Date().getTime()
  console.log "server launched, id: "+id+" waiting for configure"

handleResultFail = (lobb)->
  lob = lobbies.findOne {_id: lobb}
  lobbies.update {_id: lobb}, {$set: {status: 4}}
  MatchResults.update {_id: lobb}, {$set: {status: "completed"}, $unset: {spectate_addr: ""}}

handleFailConfigure = (serv, lobby, instance)->
  instance = pendingInstances.findOne {id: instance.id}
  return if !instance?
  console.log "failed to configure server, re-queuing lobby and disabling server"
  removeServerFromPool serv._id
  pendingInstances.remove {id: instance.id}
  lobbyQueue.remove {lobby: lobby._id}
  startFindServer lobby._id

finalizeInstance = (serv, lobby, instance)->
  lobbies.update {_id: lobby._id}, {$set: {status: 3, serverIP: serv.ip+":"+instance.port, instance: instance.id}}
  result =
    _id: lobby._id
    date: new Date().getTime()
    match_id: lobby._id
    mod: lobby.mod
    num_players: [lobby.radiant.length, lobby.dire.length]
    server_addr: lobby.serverIP
    spectate_addr: serv.ip+":"+(instance.port+1000)
    status: "loading"
    uids: []
  addPlayer = (team, lobP)->
    team.push
      last_hits: 0
      gold_per_min:0
      account_id:lobP.steam
      support_gold:0
      deaths:0
      kills:0
      hero_id:0
      last_time_seen:0
      hero_damage:0
      denies:0
      items:[0,0,0,0,0,0]
      level:1
      gold:0
      tower_damage:0
      assists:0
      hero_healing:0
      leaver_status:0
      gold_spent:0
      misses:0
      ability_upgrades:[]
      name: lobP.name
      avatar: lobP.avatar.full
  radiant = []
  dire = []
  for player in lobby.radiant
    addPlayer radiant, player
    result.uids.push player._id
  for player in lobby.dire
    addPlayer dire, player
    result.uids.push player._id
  result.teams = [{players:dire},{players:radiant}]
  MatchResults.insert result
  pendingInstances.remove {id: instance.id}

findServerForLobby = (lobby)->
  query =
    enabled: true
    $where: "this.activeLobbies.length<this.maxLobbies"
  if lobby.region isnt 0
    query.region = lobby.region
  console.log JSON.stringify query
  servs = servers.find(query).fetch()
  maxLobbies = Number.MAX_VALUE
  chosen = null
  for serv in servs
    if serv.activeLobbies.length < maxLobbies
      chosen = serv
      maxLobbies = serv.activeLobbies
  return if !chosen?
  chosen

queueProcR = ->
  #for each region try to find a server for the lobby
  sortr = {sort: {started: 1}}
  for name, id of REGIONS
    que = lobbyQueue.findOne {region: id}, sortr
    continue if !que?
    lobby = lobbies.findOne {_id: que._id}
    serv = findServerForLobby lobby
    continue if !serv?
    log.info "[QUEUE] Found server #{serv.ip} for #{lobby._id} region #{name}."
    launchServer(serv, lobby._id)
    lobbyQueue.remove({_id: que._id})
queueProc = _.debounce ->
  new Fiber(queueProcR).run()
, 150

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
    portRangeStart: 3000
    portRangeStop: 3100
    region: 0
    name: "Unknown"
  ourID = null
  serverObj.ip = ws.upgradeReq.connection.remoteAddress
  log.info "[SERVER] New server #{serverObj.ip}"
  ws.on 'close', ->
    new Fiber(->
      if ourID?
        servObj = servers.findOne {_id: serverObj._id}
        return if !servObj?
        for sess in pendingInstances.find({ip: servObj.ip})
          lob = lobbies.findOne {_id: sess.lobby}
          continue if !lob?
          handleFailConfigure serverObj, lob, {id: sess.id}
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
            log.info "[SERVER] #{serverObj.ip} failed auth"
            ws.send 'authFail'
            return
          if splitMsg[4] isnt serverVersion
            log.info "[SERVER] #{serverObj.ip} Old version (#{splitMsg[4]}) updating (#{serverVersion})"
            ws.send 'outOfDate|'+getBundleDownloadURL("s"+serverVersion+".zip")
            return
          serverObj.maxLobbies = parseInt(splitMsg[2])
          serverObj.region = parseInt splitMsg[6]
          serverObj.name = splitMsg[7]
          versions = splitMsg[3].split ','
          installStr = getAddonInstalls(versions)
          prange = splitMsg[5].split '-'
          serverObj.portRangeStart = parseInt prange[0]
          serverObj.portRangeEnd = parseInt prange[1]
          if splitMsg[8] isnt ""
            serverObj.ip  = splitMsg[8]
          if installStr is "|"
            log.info "[SERVER] #{serverObj.ip} Initialized, region #{REGIONSH[serverObj.region]} name #{serverObj.name}."
            if !serverObj._id?
              ourID = servers.insert serverObj
              serverObj._id = ourID
              sockets[ourID] = ws
          else
            console.log "told host to perform ops: "+installStr
            ws.send 'addonOps|'+installStr
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
          sess = serverObj.activeLobbies.splice serverObj.activeLobbies.indexOf(lobIdx), 1
          sess = sess[0]
          lob = lobbies.findOne {_id: sess.lobby}
          return if !lob?
          if lob.status is 2
            handleFailConfigure serverObj, lob, {id: sess.id}
          else if lob.state < GAMESTATE.PostGame
            handleLoadFail lob._id
          else if lob.state >= GAMESTATE.PostGame
            handleResultFail lob._id
          servers.update {_id: ourID}, {$set: {activeLobbies: serverObj.activeLobbies}}
          queueProc()
    ).run()
