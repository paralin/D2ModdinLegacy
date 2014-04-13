Template.home.backUrl = ->
  settings = Settings.findOne({type: "homebg"})
  if !settings?
    "/images/homeback.jpg"
  else
    settings.image
