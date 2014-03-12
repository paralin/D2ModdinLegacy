Template.modlist.helpers
  "modPath": ->
    return Router.routes['modDetail'].path({name: @name})
  "lobbyPath": ->
    return Router.routes['lobbyList'].path({name: @name})
