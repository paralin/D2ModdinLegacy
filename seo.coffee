if Meteor.isClient
  Meteor.startup ->
    SEO.config
      title: "Dota 2 Custom Game Platform"
      meta:
        description: "Play community-created custom Dota 2 game modes."
      og:
        image: "http://d2modd.in/images/D2Logo.png"
if Meteor.isServer
  Meteor.startup ->
    SeoCollection.remove({})
    SeoCollection.insert
      route_name: 'mods'
      title: 'D2MP Mod List'
      meta:
        'description': 'List of available game modes on D2Moddin.'
    SeoCollection.insert
      route_name: 'lobbies'
      title: 'Lobby List'
      meta:
        'description': 'List of active lobbies on D2Moddin.'
    SeoCollection.insert
      route_name: 'matches'
      title: 'Recent Matches'
      meta:
        'description': 'List of recently finished matches on D2Moddin.'
    SeoCollection.insert
      route_name: 'users'
      title: 'Player List'
      meta:
        'description': 'View active players on the D2Moddin network.'
