Router.map ->
  @route 'results',
    path: '/results'
    waitOn: ->
      [Meteor.subscribe("resultList"), Meteor.subscribe("modThumbList")]
    template: 'resultList'
  @route 'matchResult',
    path: '/result/:id'
    template: 'matchResult'
    waitOn: ->
      [Meteor.subscribe("matchResult", @params.id)]
    data: ->
      match = MatchResults.findOne(_id: @params.id)
      if !match?
        return @redirect Router.routes["results"].path()
      Session.set "thisMatch", match
      match
