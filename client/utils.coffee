@cSpectateGame = (resid)->
  Meteor.call "spectateGame", resid, (err, res)->
    if err?
      if err.error is 503
        Router.routes["install"].path({mod: err.reason})
      else
        $.pnotify
          title: "Problem Spectating"
          type: "error"
          text: err.reason
    else
      $.pnotify
        title: "Spectating"
        text: "Your mod manager has told Dota to spectate the game."
        type: "success"
