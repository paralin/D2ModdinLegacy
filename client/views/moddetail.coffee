Template.modDetail.notPlayable = ->
  not @playable
Template.modDetail.helpers
  playNow: ->
    if @playable
      Router.routes["lobbyList"].path({name: @name})
    else
      '#'
