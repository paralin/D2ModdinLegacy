Router.map ->
  @route 'results',
    path: '/results/:page?'
    waitOn: ->
      [Meteor.subscribe("resultList", Session.get('resultPage')), Meteor.subscribe("modThumbList")]
    action: ->
      @render "resultList"
      Session.set "resultPage", parseInt(@params.page) || 1
  @route 'matchResult',
    path: '/result/:id'
    template: 'matchResult'
    waitOn: ->
      [Meteor.subscribe("matchResult", @params.id), Meteor.subscribe("modThumbList")]
    data: ->
      match = MatchResults.findOne(_id: @params.id)
      if !match?
        return @redirect Router.routes["results"].path()
      Session.set "thisMatch", match
      match