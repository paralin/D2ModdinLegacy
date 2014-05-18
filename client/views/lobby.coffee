#Constants
radiantSlots = 5
direSlots = 5
stream = null
streamSetup = false
pushChatMessage = (msg)->
  box = $(".chatBox")
  box.val(box.val()+"\n"+msg)
  console.log "chat message: "+msg
  #scroll down
  box.scrollTop(box[0].scrollHeight)

wasInLobby = false
wasLobbyID = 0
targetFindTime = 30000 #30 seconds average?
Meteor.startup ->
  Session.set "servProgress", 50
  Deps.autorun -> #Loading bar tick
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
    lobby = findUserLobby Meteor.userId()
    return if !lobby?
    route = Router.current()
    return if !route?
    if route.route.name isnt "lobby"
      Router.go Router.routes["lobby"].path({id: lobby._id})
  Deps.autorun -> #Server status change
    lobby = lobbies.findOne({status: {$ne: null}})
    return if !lobby?
    status = lobby.status
    if status is 1
      $.pnotify
        title: "Finding a server"
        text: "Waiting for an open server slot."
        type: "info"
        delay: 5000
        closer: false
        sticker: false
  Deps.autorun -> #Chat callbacks
    lobby = lobbies.findOne({status: {$ne: null}})
    if !lobby?
      streamSetup = false
      return
    return if streamSetup
    route = Router.current()
    return if !route?
    return if route.route.name isnt "lobby"
    stream = chatStream[lobby._id]
    return if !stream?
    streamSetup = true
    stream.on "message", pushChatMessage
    wasInLobby = true
    wasLobbyID = lobby._id
  Deps.autorun -> #Leave when game is over
    route = Router.current()
    return if !route?
    if route.route.name isnt "lobby"
      wasInLobby = false
      return
    lobby = lobbies.findOne({status: {$ne: null}})
    if !lobby? and wasInLobby
      Router.go Router.routes["matchResult"].path({id: wasLobbyID})
      $.pnotify
        title: "Lobby Finished"
        text: "The lobby has closed."
        delay: 5000
        closer: false
        sticker: false
      return
      
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
  return false if !lobby?
  lobby.status is 3 and (lobby.state < GAMESTATE.PostGame)

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
  'click .startBtn': ->
    Meteor.call "startGame", (err, res)->
      if err?
        $.pnotify
          title: "Can't Start"
          text: err.reason
          type: "error"
          delay: 5000
  'keypress .titleInput': (evt, template)->
    if evt.which is 13
      field = template.find(".titleInput")
      text = field.value
      Meteor.call("setLobbyName", text)
      field.blur()
  'keypress #chatInput': (evt, template)->
    if evt.which is 13
      text = template.find("#chatInput").value
      template.find("#chatInput").value = ""
      return if text is ""
      stream.emit("message", text)
      pushChatMessage Meteor.user().profile.name+": "+text
  "click .joinBtn": ->
    Meteor.call "switchTeam", @team

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
  mods.findOne()

Template.lobby.gameInProgress = ->
  lobby = findUserLobby Meteor.userId()
  return if !lobby?
  prog = (lobby.state is GAMESTATE.Playing or lobby.state is GAMESTATE.PreGame)
  [team, me] = locatePlayer lobby, Meteor.user().services.steam.id
  prog && me.connected

Template.lobby.emptySlotR = ->
  lobby = lobbies.findOne()
  return if !lobby? or !lobby.radiant?
  slots = []
  i = 0
  while i < (radiantSlots-lobby.radiant.length)
    slots.push({team: "radiant"})
    i++
  slots
Template.lobby.emptySlotD = ->
  lobby = lobbies.findOne()
  return if !lobby? or !lobby.dire?
  slots = []
  i = 0
  while i < (direSlots-lobby.dire.length)
    slots.push({team: "dire"})
    i++
  slots

Template.findDialog.connectURL = ->
  lobby = lobbies.findOne()
  return if !lobby? or !lobby.serverIP?
  "steam://connect/"+lobby.serverIP

Template.findDialog.progress = ->
  Session.get("servProgress")

Template.findDialog.gameOver = ->
  lobby = findUserLobby Meteor.userId()
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
  lobby = findUserLobby Meteor.userId()
  lobby? and lobby.status is 2
Template.lobby.playerClass = ->
  cl = ""
  if @connected? && !@connected
    cl += "danger"
  cl
