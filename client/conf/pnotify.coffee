$(document).ready ->
  Meteor.startup ->
    PNotify.prototype.options.styling = "bootstrap3"
    PNotify.prototype.options.history = false
    PNotify.prototype.options.stack = {"dir1": "up", "dir2": "left", "push": "left"}
    PNotify.prototype.options.addclass = "stack-bottomright"
    PNotify.prototype.options.nonblock = {nonblock: true, nonblock_opacity: 0.2}
    PNotify.prototype.options.closer = false
    PNotify.prototype.options.sticker = false
    PNotify.prototype.options.hide = true
    PNotify.prototype.options.delay = 2000
    $.pnotify = (options)->
      new PNotify options
