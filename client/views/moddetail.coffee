Template.modDetail.helpers
  playNow: ->
    if @playable
      Router.routes["lobbyList"].path({name: @name})
    else
      $.pnotify
        title: 'Not Playable'
        text: 'This mod is not available to play yet.'
        type: 'error'
