@clientParams = new Meteor.Collection "clientParams"
urlBase = "https://s3-us-west-2.amazonaws.com/d2mpclient/"

Meteor.startup ->
  clientParams.remove({})
  clientParams.insert
    stype: "version"
    version: "0.6.4"

Router.map ->
  @route 'clientver',
    where: 'server'
    path: '/clientver'
    action: ->
      info = clientParams.findOne({stype: "version"})
      @response.writeHead 200, {'Content-Type': 'text/html'}
      @response.end 'version:'+info.version+'|'+urlBase+info.version+".zip"
