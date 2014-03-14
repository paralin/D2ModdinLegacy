#Constants
radiantSlots = 5
direSlots = 5

streamSetup = false
pushChatMessage = (msg)->
  box = $(".chatBox")
  box.val(box.val()+"\n"+msg)
  console.log "chat message: "+msg
  #scroll down
  box.scrollTop(box[0].scrollHeight)

Meteor.startup ->
  Deps.autorun -> #Detect if we're in a lobby
    lobby = lobbies.findOne({status: {$ne: null}})
    return if !lobby?
    route = Router.current()
    return if !route?
    if route.route.name isnt "lobby"
      Router.go Router.routes["lobby"].path({id: lobby._id})
  Deps.autorun -> #Chat callbacks
    lobby = lobbies.findOne({status: {$ne: null}})
    if !lobby?
      streamSetup = false
      return
    return if streamSetup
    route = Router.current()
    return if !route?
    return if route.route.name isnt "lobby"
    return if !chatStream?
    streamSetup = true
    chatStream.on "message", pushChatMessage

Template.lobby.statusIs = (st)->
  lobby = lobbies.findOne()
  return false if !lobby?
  lobbies.findOne().status is st
Template.lobby.events
  'click .stopBtn': ->
    Meteor.call "stopFinding"
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
      chatStream.emit("message", text)
      pushChatMessage Meteor.user().profile.name+": "+text

Template.lobby.isHost = ->
  user = Meteor.userId()
  return if !user?
  lobby = lobbies.findOne()
  return if !lobby?
  user is lobby.creatorid

Template.lobby.lobby = ->
  lobbies.findOne()

Template.lobby.status = ->
  lobby = lobbies.findOne()
  return if !lobby? or !lobby.status?
  switch lobby.status
    when 0 then return "Waiting for players..."
    when 1 then return "Searching for a server..."
    when 2 then return "Playing! Hit connect."
    when 3 then return "Game has ended."
Template.lobby.events
  "click .joinBtn": ->
    Meteor.call "switchTeam", @team
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
