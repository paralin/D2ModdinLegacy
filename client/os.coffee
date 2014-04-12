Template.osmessage.rendered = ->
  apv = navigator.appVersion
  console.log apv
  if !apv? || apv.indexOf("Win") is -1
    console.log "wrong os"
    notification =
      title: "OS Not Supported"
      text: "D2Moddin currently only works on Windows."
      type: "error"
      sticker: false
      hide: false
      closer: false
    $.pnotify notification
    console.log notification
