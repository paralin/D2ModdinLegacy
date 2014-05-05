Template.osmessage.rendered = ->
  apv = navigator.appVersion
  if apv? && apv.indexOf("Win") is -1
    notification =
      title: "OS Not Supported"
      text: "D2Moddin currently only works on Windows."
      type: "error"
      sticker: false
      hide: false
      closer: false
    $.pnotify notification
  if apv? && apv.indexOf("GameOverlay") isnt -1
    notification =
      title: "Steam Overlay Not Supported"
      text: "This site won't work with the steam overlay browser."
      type: "error"
      sticker: false
      hide: false
      closer: false
    $.pnotify notification
