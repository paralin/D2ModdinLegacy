Template.home.backUrl = ->
  settings = Settings.findOne({type: "homebg"})
  if !settings?
    ""
  else
    settings.image
