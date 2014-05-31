handleEvents = (id, eves)->
  for eve in eves
    evestring = EVENTSK[eve.event_type]
    if !evestring?
      log.error "Unknown event #{eve.event_type} received."
      continue
    log.debug "[EVENT] #{evestring} received"
    handleEvent id, eve
   
Router.map ->
  @route 'gmatchresult',
    where: 'server'
    path: '/gdataapi/matchres'
    action: ->
      data = @request.body
      if !data.status? || !data.match_id?
        @response.writeHead 500, {'Content-Type': 'text/html'}
        @response.end 'invalid data'
        return
      #findFaster the referenced match
      lobby = lobbies.findOneFaster {_id: data.match_id}
      result = MatchResults.findOneFaster {_id: data.match_id}
      if !lobby? || !result?
        log.error "Received match event with unknown lobby/result #{data.match_id}"
        return
      switch data.status
        when "events" then handleEvents data.match_id, data.events
        when "completed" then handleMatchComplete data.match_id, data
        when "load_failed" then handleLoadFail data.match_id
        else
          log.error "Unknown match result data: #{data.status}"
      @response.writeHead(200, {'Content-Type': 'text/html'})
      @response.end('accepted')
