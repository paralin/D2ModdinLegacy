Meteor.methods
  "spectateGame": (resid)->
    if !@userId?
      throw new Meteor.Error 403, "You must be logged in."
    client = clients.findOneFaster {_id: @userId}
    if !client?
      throw new Meteor.Error 404, "Your mod manager is not running."
    result = MatchResults.findOneFaster {_id: resid}
    if !result?
      throw new Meteor.Error 404, "Can't findFaster that game."
    mod = mods.findOneFaster {name: result.mod, playable: true}
    if !mod?
      throw new Meteor.Error 404, "Mod #{result.mod} not found or not public/playable."
    ver = mod.name+"="+mod.version
    if _.contains(client.installedMods, ver)
      setMod user, ver
      return result.spectate_addr
    else
      throw new Meteor.Error 503, mod.name
  "installMod": (modName)->
    filter =
      name: modName
    if !AuthManager.userIsInRole @userId, ["admin", "developer", "moderator", "spectator"]
      filter.public = true
      filter.playable = true
    mod = mods.findOneFaster filter
    if !mod?
      throw new Meteor.Error 404, "Mod "+modName+" not found or not public/playable."
    if !@userId?
      throw new Meteor.Error 403, "You must be logged in."
    client = clients.findOneFaster({_id: @userId})
    if !client?
      throw new Meteor.Error 404, "Your client is not running."
    ver = mod.name+"="+mod.version
    if _.contains(client.installedMods, ver)
      throw new Meteor.Error 410, "#{ver} is already installed and ready to play."
    installMod @userId, mod
