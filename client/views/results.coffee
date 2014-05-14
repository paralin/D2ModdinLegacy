Template.resultList.results = ->
  MatchResults.find({}, {sort: {date:-1}})
Template.resultList.inProgress = ->
  @status? && @status isnt "completed"
Template.resultList.inProgressClass = ->
  "info" if @status? && @status isnt "completed"
Template.resultList.events
  'click .specBtn': ->
    cSpectateGame @_id
Template.matchResult.canSpectate = Template.resultList.canSpectate = ->
  @status? && @status is "playing"
Template.matchResult.events
  'click .specBtn': ->
    cSpectateGame @_id
Template.resultList.thisMod = ->
  mod = mods.findOne {name: @mod}
  if !mod?
    return {thumbnail: ""}
  mod
Template.matchResult.getMod = Template.resultList.thisMod
Template.resultList.resultURI = ->
  Router.routes["matchResult"].path {id: @_id}
Template.gameTeamStats.dire = ->
  match = MatchResults.findOne()
  return if !match?
  match.teams[0].players
Template.gameTeamStats.radiant = ->
  match = MatchResults.findOne()
  return if !match?
  match.teams[1].players
Template.gameTeamStats.playerClass = ->
  if @connected? && !@connected
    "danger"
Template.gameTeamStats.isCompleted = Template.matchResult.isCompleted = ->
  !@status? || @status is "completed"
  
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
