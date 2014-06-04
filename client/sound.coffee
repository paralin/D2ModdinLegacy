@matchFoundSound = new buzz.sound('https://s3-us-west-2.amazonaws.com/d2mpclient/match_ready.ogg')

soundPlayed = false
Meteor.startup ->
  Meteor.autorun ->
    lobby = lobbies.findOne()
    return if !lobby?
    if lobby.status is 3
      matchFoundSound.play() if !soundPlayed
      soundPlayed = true
    else
      soundPlayed = false
