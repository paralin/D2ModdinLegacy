###
#Fill the DB with hard-coded mods
###

Meteor.startup ->
  modJSON = Assets.getText "mods.json"
  return if !modJSON?
  data = JSON.parse modJSON
  mods.remove({})
  for mod in data
    mods.insert mod
