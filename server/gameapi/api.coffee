#General API functions for ingame VScript
#http://d2modd.in/gscriptapi/:rcon_password/method/:data
rerr = (response, err)->
  response.writeHead(500, {'Content-Type': 'text/html'})
  response.end(err)
rsucc = (response, msg)->
  response.writeHead(200, {'Content-Type': 'text/html'})
  response.end msg
Router.map ->
  @route "gsplayerconnect",
    where: 'server'
    path: '/gscriptapi/pconnect/:rcon_password'
    action: ->
      rpass = @params.rcon_password
      console.log JSON.stringify @request.body
      if !rpass?
        return rerr @response, "Invalid paramaters."
      rsucc @response, "SUCCESS"
  @route "gsplayerdisconnect",
    where: 'server'
    path: '/gscriptapi/pdisconnect/:rcon_password'
    action: ->
      rpass = @params.rcon_password
      console.log JSON.stringify @request.body
      if !rpass?
        return rerr @response, "Invalid paramaters."
      rsucc @response, "SUCCESS"
