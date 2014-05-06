Meteor.methods
  "installMod": (modName)->
    mod = mods.findOne({name: modName, public: true, playable: true})
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
