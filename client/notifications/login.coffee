Meteor.startup ->
  Deps.autorun ->
    val = Session.get "Meteor.loginButtons.errorMessage"
    Accounts._loginButtonsSession.errorMessage "Invited players only!"
