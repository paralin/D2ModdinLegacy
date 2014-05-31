@mods = new Meteor.Collection null

Deps.autorun ->
  status = Meteor.status()
  return if !status.connected
  Meteor.call "getMods", (err, list)->
    if err?
      console.log "Error retreiving mods #{err}"
      return
    mods.remove({})
    for mod in list
      mods.insert mod
