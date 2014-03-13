#Constants
radiantSlots = 5
direSlots = 5
Template.lobby.status = ->
  lobby = lobbies.findOne()
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
  slots = []
  i = 0
  while i < (radiantSlots-lobby.radiant.length)
    slots.push({team: "radiant"})
    i++
  slots
Template.lobby.emptySlotD = ->
  lobby = lobbies.findOne()
  slots = []
  i = 0
  while i < (direSlots-lobby.dire.length)
    slots.push({team: "dire"})
    i++
  slots

