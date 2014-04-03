###
#Fill the DB with hard-coded addons
###

Meteor.startup ->
  if ServerAddons.find().count() is 0
    ServerAddons.insert
      name: "d2fixups"
      version: "0.1"
      bundle: "serv_d2fixups.zip"
    ServerAddons.insert
      name: "lobby"
      version: "0.2"
      bundle: "serv_lobby.zip"
    ServerAddons.insert
      name: "metamod"
      version: "0.1"
      bundle: "serv_metamod.zip"
    ServerAddons.insert
      name: "rota"
      version: "0.3.7"
      bundle: "serv_rota.zip"
    ServerAddons.insert
      name: "sourcemod"
      version: "0.1"
      bundle: "serv_sourcemod.zip"
    ServerAddons.insert
      name: "pudgewars"
      version: "0"
      bundle: "serv_pudgewars.zip"
