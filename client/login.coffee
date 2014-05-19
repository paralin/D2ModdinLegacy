Meteor.startup ->
  Deps.autorun ->
    metric = Metrics.findOne {_id: 'login'}
    val = Session.get "Meteor.loginButtons.errorMessage"
    if metric? and !metric.enabled
      Accounts._loginButtonsSession.errorMessage "Signups currently disabled."
    else
      Accounts._loginButtonsSession.errorMessage ""
    
