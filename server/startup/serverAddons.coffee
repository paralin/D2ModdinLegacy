###
#Fill the DB with hard-coded addons
###

Meteor.startup ->
  ServerAddons.remove({})
  #if ServerAddons.find().count() is 0
  ServerAddons.insert
    name: "d2fixups"
    version: "0.2"
    bundle: "serv_d2fixups.zip"
  ServerAddons.insert
    name: "lobby"
    version: "0.3"
    bundle: "serv_lobby.zip"
  ServerAddons.insert
    name: "metamod"
    version: "0.3.1"
    bundle: "serv_metamod.zip"
  ServerAddons.insert
    name: "rota"
    version: "0.3.7"
    bundle: "serv_rota.zip"
  ServerAddons.insert
    name: "pudgewars"
    version: "0.12"
    bundle: "serv_pudgewars.zip"
  ServerAddons.insert
    name: "vscript_http"
    version: "0.1"
    bundle: "serv_vscript_http.zip"
