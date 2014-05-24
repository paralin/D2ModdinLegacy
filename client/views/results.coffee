Template.resultList.hideLive = ->
  Session.get "hideLive"
Template.resultList.hideNotMe = ->
  Session.get "hideNotMe"
Template.resultList.rightClass = ->
  page = Session.get("resultPage")
  return if !page?
  totalMatches = (Metrics.findOne({_id: "matches"}) || {count: 0}).count
  totalPages = Math.ceil(totalMatches/10)
  return "disabled" if page is totalPages
  ""
Template.resultList.leftClass = ->
  page = Session.get("resultPage")
  return if !page?
  return "disabled" if page is 1
  ""
Template.resultList.leftPath = ->
  page = Session.get("resultPage")
  return if !page? or page is 1
  Router.routes["results"].path page: parseInt(page)-1
Template.resultList.rightPath = ->
  page = Session.get("resultPage")
  return if !page?
  totalMatches = (Metrics.findOne({_id: "matches"}) || {count: 0}).count
  totalPages = Math.ceil(totalMatches/10)
  return if page is totalPages
  Router.routes["results"].path page: parseInt(page)+1
Template.resultList.results = ->
  MatchResults.find({}, {sort: {date:-1}})
Template.resultList.inProgress = ->
  @status? && @status isnt "completed"
Template.resultList.inProgressClass = ->
  "info" if @status? && @status isnt "completed"
Template.resultList.events
  'click .hideNotMe': ->
    curr = Session.get "hideNotMe"
    curr = false if !curr?
    Session.set "hideNotMe", !curr
  'click .hideLive': ->
    curr = Session.get "hideLive"
    curr = false if !curr?
    Session.set "hideLive", !curr
  'click .specBtn': ->
    cSpectateGame @_id
Template.matchResult.canSpectate = Template.resultList.canSpectate = ->
  #false
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
  page = Session.get "resultPage"
  res = while totalPages-=1
    {
      selected: parseInt(page) is totalPages
      num: totalPages
    }
  res.reverse()
