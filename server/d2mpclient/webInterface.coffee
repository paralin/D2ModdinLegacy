Meteor.methods
  "spectateGame": (resid)->
    if !@userId?
      throw new Meteor.Error 403, "You must be logged in."
    user = Meteor.users.findOne {_id: @userId}
    client = clients.findOne {steamIDs: user.services.steam.id}
    if !client?
      throw new Meteor.Error 404, "Your mod manager is not running."
    result = MatchResults.findOne {_id: resid}
    if !result?
      throw new Meteor.Error 404, "Can't find that game."
    mod = mods.findOne {name: result.mod, playable: true}
    if !mod?
      throw new Meteor.Error 404, "Mod #{result.mod} not found or not public/playable."
    ver = mod.name+"="+mod.version
    if _.contains(client.installedMods, ver)
      setMod user, ver
      #dspectate user, result.spectate_addr
      return result.spectate_addr
    else
      throw new Meteor.Error 503, mod.name
  "installMod": (modName)->
    filter =
      name: modName
      playable: true
    if !AuthManager.userIsInRole @userId, ["admin", "developer", "moderator", "spectator"]
      filter.public = true
    mod = mods.findOne filter
    if !mod?
      throw new Meteor.Error 404, "Mod "+modName+" not found or not public/playable."
    if !@userId?
      throw new Meteor.Error 403, "You must be logged in."
    user = Meteor.users.findOne {_id: @userId}
    client = clients.findOne({steamIDs: user.services.steam.id})
    if !client?
      throw new Meteor.Error 404, "Your client is not running."
    ver = mod.name+"="+mod.version
    if _.contains(client.installedMods, ver)
      throw new Meteor.Error 410, "#{ver} is already installed and ready to play."
    installMod client, mod
