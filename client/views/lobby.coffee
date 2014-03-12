Template.lobby.status = ->
  lobby = lobbies.findOne()
  switch lobby.status
    when 0 then return "Waiting for players..."
    when 1 then return "Searching for a server..."
    when 2 then return "Playing! Hit connect."
    when 3 then return "Game has ended."
