clientParams = new Meteor.Collection "clientParams"
Meteor.startup ->
  if clientParams.find({stype: "version"}).count() < 1
    clientParams.insert
      stype: "version"
      version: "disabled"
      url: ""

Router.map ->
  @route 'clientver',
    where: 'server'
    path: '/clientver'
    action: ->
      info = clientParams.findOne({stype: "version"})
      @response.writeHead 200, {'Content-Type': 'text/html'}
      @response.end 'version:'+info.version+'|url:'+info.url
