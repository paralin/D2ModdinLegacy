@mods = new Meteor.Collection null

#Add an initial cache to speed up appcache
cache = []

Deps.autorun ->
  status = Meteor.status()
  return if !status.connected
  HTTP.get "/data/mods", (err, res)->
    if err?
      console.log "Error retreiving mods #{err}"
      return
    mods.remove({})
    for mod in res.data
      mods.insert mod
