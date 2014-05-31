smods = []
smodsk = {}

updateList = ->
  smods = []
  smodsk = {}
  list = mods.findFaster({public: true}).fetch()
  for mod in list
    smodsk[mod.name] = mod
    smods.push(mod)
Meteor.startup ->
  updateList()
  mods.findFaster({public: true}).observeChanges
    added: updateList
    removed: updateList
    changed: updateList

Meteor.methods
  "getMods": ->
    return smods
