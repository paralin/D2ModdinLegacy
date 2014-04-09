if Meteor.isServer
  Meteor.startup ->
    SeoCollection.remove()
    stdog =
      'title': 'Dota 2 Modding',
      'image': 'http://d2modd.in/images/D2Logo.png'
    SeoCollection.insert
      route_name: 'home',
      title: 'Dota 2 Mod Platform'
      meta:
        'description': 'Play community-created custom Dota 2 game modes.'
      og: stdog
    SeoCollection.insert
      route_name: 'mods'
      title: 'Mod List'
      meta:
        'description': 'List of available mods on D2Moddin.'
      og: stdog
    SeoCollection.insert
      route_name: 'lobbies'
      title: 'Lobby List'
      meta:
        'description': 'List of active lobbies on D2Moddin.'
      og: stdog
    SeoCollection.insert
      route_name: 'matches'
      title: 'Recent Matches'
      meta:
        'description': 'List of recently finished matches on D2Moddin.'
      og: stdog
    SeoCollection.insert
      route_name: 'users'
      title: 'Player List'
      meta:
        'description': 'View active players on the D2Moddin network.'
      og: stdog
