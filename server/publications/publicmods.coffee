Meteor.publish "modDetails", (name) ->
  mods.findFaster
    name: name
  ,
    fields:
      name: 1
      fullname: 1
      author: 1
      authorimage: 1
      spreadimage: 1
      website: 1
      subtitle: 1
      thumbnail: 1
      features: 1
      description: 1
      spreadvideo: 1
      playable: 1
    reactive: false
Meteor.publish "modDetailsForLobby", ->
  user = null
  @stop() if !@userId?
  lobby = findUserLobby @userId
  @stop() if !lobby?
  mods.findFaster
    name: lobby.mod
  ,
    fields:
      name: 1
      fullname: 1
      author: 1
      thumbnail: 1
      subtitle: 1

Meteor.publish "modList", ->
  mods.findFaster
    public: true
  ,
    fields:
      name: 1
      fullname: 1
      author: 1
      authorimage: 1
      thumbnail: 1
      subtitle: 1
      playable: 1

Meteor.publish "modThumbList", ->
  mods.findFaster {},
    fields:
      name: 1
      fullname: 1
      author: 1
      thumbnail: 1
      subtitle: 1
      playable: true
