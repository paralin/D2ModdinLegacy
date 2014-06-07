@mods = new Meteor.Collection "mods"
smods = []
smodsk = {}

updateList = ->
  smods = []
  smodsk = {}
  list = mods.findFaster({isPublic: true}).fetch()
  for mod in list
    smodsk[mod.name] = mod
    smods.push(mod)
Meteor.startup ->
  updateList()
  mods.findFaster({isPublic: true}).observeChanges
    added: updateList
    removed: updateList
    changed: updateList

Router.map ->
  @route "moddata",
    where: "server"
    path: "/data/mods"
    action: ->
      @response.writeHead 200,
        "Content-Type": "application/json"
      @response.end JSON.stringify smods
