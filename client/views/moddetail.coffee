Template.modDetail.helpers
  playNow: ->
    Router.routes["lobbyList"].path({name: @name})
