Router.map ->
  @route 'results',
    path: '/results/:page?'
    fastRender: true
    waitOn: ->
      filter = {}
      [Meteor.subscribe("resultList")]
    action: ->
      @render "resultList"
      Session.set "resultPage", parseInt(@params.page) || 1
  @route 'matchResult',
    path: '/result/:id'
    template: 'matchResult'
    fastRender: true
    waitOn: ->
      [Meteor.subscribe("matchResult", @params.id)]
    data: ->
      match = MatchResults.findOne(_id: @params.id)
      if !match?
        return @redirect Router.routes["results"].path()
      Session.set "thisMatch", match
      match
