UI.registerHelper 'regionName', (id)->
  REGIONSH[id]
UI.registerHelper 'regionNames', ->
  res = []
  for id, name of REGIONSH
    res.push
      key: id
      value: name
  res
@cSpectateGame = (resid)->
  Meteor.call "spectateGame", resid, (err, res)->
    if err?
      if err.error is 503
        Router.go Router.routes["install"].path({mod: err.reason})
      else
        $.pnotify
          title: "Problem Spectating"
          type: "error"
          text: err.reason
    else
      prompt "Copy this command and paste it in the Dota 2 console to spectate this game.", "connect_hltv #{res}"
