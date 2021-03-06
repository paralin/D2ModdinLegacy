@clientParams = new Meteor.Collection "clientParams"
urlBase = "https://s3-us-west-2.amazonaws.com/d2mpclient/"
Router.map ->
  @route 'clientver',
    where: 'server'
    path: '/clientver'
    action: ->
      info = clientParams.findOneFaster({stype: "version"})
      @response.writeHead 200, {'Content-Type': 'text/html'}
      @response.end 'version:'+info.version+'|'+urlBase+info.version+".zip"
