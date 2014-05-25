Meteor.startup ->
  notification = null
  unrender = ->
    if notification?
      notification.remove()
      notification = null
  render = ->
    status = Meteor.status()
    message = ""
    switch status.status
      when "waiting"
        message = "Your browser will try to connect again #{moment(status.retryTime).fromNow()}."
      else
        message = "Your browser is attempting to connect..."
    options =
      title: "Connecting..."
      text: message
      type: "error"
      hide: false
      buttons:
        closer: false
        sticker: false
    if !notification?
      notification = $.pnotify options
    else
      notification.update options
  Deps.autorun ->
    status = Meteor.status()
    if status.connected
      unrender()
    else
      render()
