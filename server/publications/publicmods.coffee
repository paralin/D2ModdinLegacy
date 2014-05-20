
#General mod info for the list
Meteor.publish "modDetails", (name) ->
  mods.find
    name: name
    public: true
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
Meteor.publish "modDetailsForLobby", ->
  user = null
  @stop() if !@userId?
  lobby = findUserLobby @userId
  @stop() if !lobby?
  mods.find
    name: lobby.mod
  ,
    fields:
      name: 1
      fullname: 1
      author: 1
      thumbnail: 1
      subtitle: 1

Meteor.publish "modList", ->
  mods.find
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
  mods.find
    public: true
  ,
    fields:
      name: 1
      fullname: 1
      author: 1
      thumbnail: 1
      subtitle: 1
      playable: true
