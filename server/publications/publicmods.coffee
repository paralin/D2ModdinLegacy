smods = []
smodsk = {}

Meteor.startup ->
  list = mods.find({public: true}).fetch()
  for mod in list
    smodsk[mod.name] = mod
    smods.push(mod)

Meteor.methods
  "getMods": ->
    return smods
