Template.modlist.isDisabled = ->
  !@playable
Template.modlist.modPath = ->
  Router.routes['modDetail'].path({name: @name})
Template.modlist.lobbyPath = ->
  Router.routes['lobbyList'].path({name: @name})
