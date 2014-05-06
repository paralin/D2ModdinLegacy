###
#Fill the DB with hard-coded addons
###

Meteor.startup ->
  baseJSON = Assets.getText "serveraddons.json"
  base = EJSON.parse baseJSON
  modsJSON = Assets.getText "smods.json"
  mods = EJSON.parse modsJSON
  addons = _.union base, mods
  ServerAddons.remove({})
  for addon in addons
    ServerAddons.insert addon
