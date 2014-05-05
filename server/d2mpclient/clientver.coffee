@clientParams = new Meteor.Collection "clientParams"
Meteor.startup ->
  if clientParams.find({stype: "version"}).count() < 1
    clientParams.insert
      stype: "version"
      version: "0.5.2"
      url: "https://s3-us-west-2.amazonaws.com/d2mpclient/0.5.2.zip"

Router.map ->
  @route 'clientver',
    where: 'server'
    path: '/clientver'
    action: ->
      info = clientParams.findOne({stype: "version"})
      @response.writeHead 200, {'Content-Type': 'text/html'}
      @response.end 'version:'+info.version+'|'+info.url
