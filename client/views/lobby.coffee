radiantSlots = 5
direSlots = 5
wasInLobby = false
wasLobbyID = 0
targetFindTime = 30000 #30 seconds average?

@pushChatMessage = (msg)->
  box = $(".chatBox")
  return if box.length is 0
  box.val(box.val()+"\n"+msg)
  box.scrollTop(box[0].scrollHeight)

Meteor.startup ->
  Session.set "servProgress", 50
  Deps.autorun ->
    curr = Session.get "servProgress"
    lobby = lobbies.findOne()
    startTime = Session.get "findStartTime"
    currTime = Session.get "500mstick"
    Session.set "servTimeElapsed", Math.floor((currTime-startTime)/1000)
    if !lobby? or lobby.status is 0
      Session.set "servProgress", 0
      Session.set "findStartTime", 0
    else if lobby.status is 1
      if Session.get("findStartTime") is 0
        Session.set "findStartTime", new Date().getTime()
      prog = (currTime-startTime)/targetFindTime*100
      if prog > 75
        targetFindTime += 30000
      Session.set "servProgress", prog
      Session.set "servProgColor", "info"
    else if lobby.status is 2
      Session.set "servProgress", 80
      Session.set "servProgColor", "warning"
    else if lobby.status is 3
      Session.set "servProgress", 100
      Session.set "servProgColor", "success"
  Deps.autorun -> #Detect if we're in a lobby
    route = Router.current()
    return if !route?
    user = Meteor.user()
    return if !user?
    lobby = lobbies.findOne()
    if route.route.name is "lobby" and !lobby?
      Router.go Router.routes["lobbyList"].path()
      return
    else if route.route.name isnt "lobby"
      if lobby?
        Router.go Router.routes["lobby"].path({id: lobby._id})
        wasInLobby = true
        wasLobbyID = lobby._id

Template.lobby.statusIs = (st)->
  lobby = lobbies.findOne()
  return false if !lobby?
  lobby.status is st

Template.lobby.showPlayerList = ->
  lobby = lobbies.findOne()
  return false if !lobby?
  lobby.status is 0
Template.lobby.areFinding = ->
  lobby = lobbies.findOne()
  return false if !lobby?
  lobby.status is 1 or lobby.status is 2
Template.findDialog.servProgColor = ->
  Session.get "servProgColor"
Template.findDialog.arePlaying = ->
  lobby = lobbies.findOne()
  return false if !lobby? || !lobby.status?
  lobby.status is 3# and (lobby.state < GAMESTATE.PostGame)

Template.findDialog.events
  'click .connectBtn': ->
    $(".connectBtn").prop 'disabled', true
    Meteor.setTimeout ->
      $(".connectBtn").prop 'disabled', false
    , 1500
  'click .stopFindingBtn': ->
    console.log "stop finding button"
    Meteor.call "stopFinding", (err, res)->
      if err?
        $.pnotify
          title: "Can't Stop Queuing"
          text: err.reason
          type: "error"
          delay: 5000
Template.lobby.events
  "click .leaveLobby": ->
    callMethod "leavelobby", {}
  "change .regionInput": (evt)->
    newVal = parseInt $(evt.target).val()
    callMethod "setregion", {region: newVal}
  "click .kickBtn": ->
    callMethod "kickplayer", {steam: @steam}
  'click .startBtn': ->
    Meteor.call "startGame", (err, res)->
      if err?
        $.pnotify
          title: "Can't Start"
          text: err.reason
          type: "error"
          delay: 5000
  'keypress .passwordInput': (evt, template)->
    if evt.which is 13
      field = template.find('.passwordInput')
      text = field.value
      Meteor.call "setLobbyPassword", text
      field.blur()
  'keypress .titleInput': (evt, template)->
    if evt.which is 13
      field = template.find(".titleInput")
      text = field.value
      callMethod "setname", {name: text}
      field.blur()
  "click .joinBtn": ->
    callMethod "switchteam", {team: @team}
  'keypress #chatInput': (evt, template)->
    if evt.which is 13
      input = $("#chatInput")
      text = input.val()
      input.val("")
      return if text is ""
      callMethod "chatmsg", {message: text}

Template.lobby.isHost = ->
  user = Meteor.userId()
  return if !user?
  lobby = lobbies.findOne()
  return if !lobby?
  user is lobby.creatorid

Template.findDialog.isHost = Template.lobby.isHost

Template.lobby.lobby = ->
  lobbies.findOne()

Template.lobby.status = Template.findDialog.status = ->
  lobby = lobbies.findOne()
  return if !lobby? or !lobby.status?
  if lobby.status is 3 and lobby.state >= GAMESTATE.PostGame
    return "Waiting for game results..."
  switch lobby.status
    when 0 then return "Waiting for players to be ready..."
    when 1 then return "Searching for a server..."
    when 2 then return "Server launching..."
    when 3 then return "Game in progress!"
    when 4 then return "Game has ended."
Template.lobby.mod = ->
  mods.findOne({_id: lobbies.findOne().mod})

Template.lobby.gameInProgress = ->
  #lobby = findUserLobby Meteor.userId()
  #return if !lobby? || 
  return false
  #prog = (lobby.state is GAMESTATE.Playing or lobby.state is GAMESTATE.PreGame)
  #[team, me] = locatePlayer lobby, Meteor.user().services.steam.id
  #prog && me.connected

Template.lobby.spectatorSlots = ->
  slots = @spectator
  res = []
  idx = -1
  for slot in slots
    idx++
    res.push
      index: idx
      team: "spectator"+idx
      slots: slot
  res

Template.lobby.emptySlotS = ->
  slots = []
  i = 0
  curr = _.without(@slots, null)
  while i < (4-curr.length)
    slots.push ({team: @team})
    i++
  slots
Template.lobby.emptySlotR = ->
  lobby = lobbies.findOne()
  curr = _.without(lobby.radiant, null)
  slots = []
  i = 0
  while i < (5-curr.length)
    slots.push({team: "radiant"})
    i++
  slots
Template.lobby.emptySlotD = ->
  lobby = lobbies.findOne()
  curr = _.without(lobby.dire, null)
  slots = []
  i = 0
  while i < (5-curr.length)
    slots.push({team: "dire"})
    i++
  slots

Template.findDialog.connectURL = ->
  lobby = lobbies.findOne()
  return if !lobby? or !lobby.serverIP?
  "steam://connect/"+lobby.serverIP
Template.findDialog.serverIP = ->
  lobby = lobbies.findOne()
  return if !lobby? or !lobby.serverIP?
  lobby.serverIP


Template.findDialog.progress = ->
  Session.get("servProgress")

Template.findDialog.gameOver = ->
  lobby = lobbies.findOne()
  return if !lobby?
  lobby.state >= GAMESTATE.PostGame
Template.findDialog.timeElapsed = ->
  Session.get "servTimeElapsed"
Template.findDialog.progBarClass = ->
  lobby = lobbies.findOne()
  return if !lobby?
  if Template.findDialog.arePlaying()
    "pbSmall"
  else
    "progress-striped active"
Template.findDialog.isConfiguring = ->
  lobby = lobbies.findOne()
  lobby? and lobby.status is 2
Template.lobby.playerClass = ->
  cl = ""
  if @connected? && !@connected
    cl += "danger"
  cl
