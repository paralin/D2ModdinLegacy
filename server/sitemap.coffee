sitemaps.add "/sitemap.xml", ->
  map = [
    {
      page: ""
      lastmod: new Date()
      priority: 0.2
      changefreq: "monthly"
    }
    {
      page: "mods"
      lastmod: new Date()
      priority: 0.9
      changefreq: "daily"
    }
    {
      page: "lobbies"
      lastmod: new Date()
      changefreq: "always"
    }
  ]
  mlist = mods.find().fetch()
  for mod in mlist
    map.push
      page: "mods/"+mod.name
      lastmod: new Date()
      priority: 0.8
      changefreq: "daily"
  map
