@matchFoundSound = new buzz.sound('https://s3-us-west-2.amazonaws.com/d2solo/match_ready.ogg')

soundPlayed = false
Meteor.startup ->
  Meteor.autorun ->
    user = Meteor.user()
    return if !user?
    lobby = findUserLobby Meteor.userId()
    if lobby.status is 3
      matchFoundSound.play() if !soundPlayed
      soundPlayed = true
    else
      soundPlayed = false
