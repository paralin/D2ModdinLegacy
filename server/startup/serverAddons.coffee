###
#Fill the DB with hard-coded addons
###

Meteor.startup ->
  baseJSON = Assets.getText "serveraddons.json"
  addons = EJSON.parse baseJSON
  for addon in addons
    ServerAddons.remove {name: addon.name}
    ServerAddons.insert addon
