###
#Fill the DB with hard-coded addons
###

Meteor.startup ->
  baseJSON = Assets.getText "serveraddons.json"
  addons = EJSON.parse baseJSON
  ServerAddons.remove {fetch: {$exists: false}}
  for addon in addons
    ServerAddons.remove {name: addon.name}
    ServerAddons.insert addon
