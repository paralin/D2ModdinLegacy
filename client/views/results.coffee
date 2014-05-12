Template.resultList.results = ->
  MatchResults.find()
Template.resultList.inProgressClass = ->
  "info" if @inProgress
Template.resultList.thisMod = ->
  mod = mods.findOne {name: @mod}
  if !mod?
    return {thumbnail: ""}
  mod
Template.resultList.resultURI = ->
  Router.routes["matchResult"].path {id: @_id}
Template.matchResult.dire = ->
  match = Session.get "thisMatch"
  return if !match?
  match.teams[0].players
Template.matchResult.radiant = ->
  match = Session.get "thisMatch"
  return if !match?
  match.teams[1].players
Template.matchResult.playerClass = ->
  if @disconnected? && @disconnected
    "danger"
Template.matchResult.isCompleted = ->
  @status? && @status is "completed"
Template.resultList.pagClass = ->
  cla = "pagBtn"
  if @selected
    cla+=" active"
  cla
Template.resultList.pages = ->
  totalMatches = (Metrics.findOne({_id: "matches"}) || {count: 0}).count
  totalPages = Math.ceil(totalMatches/10)+1
  while totalPages-=1
    {
      selected: false
      num: totalPages
    }
