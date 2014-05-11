Template.developer.fetches = ->
  cursor = modfetch.find()
  if cursor.count() is 0
    return null
  cursor
Template.fetchDetail.playable = ->
  mod = mods.findOne fetch: @_id
  return if !mod?
  mod.playable
Template.fetchDetail.pflip
Template.fetchDetail.disableUpdates = ->
  fetch = modfetch.findOne
    _id: Router.current().options.params.id
  return if !fetch?
  fetch.status isnt 0
Template.developer.events
  "click .servt tr": ->
    Router.go Router.routes["fetchDetail"].path({id: @_id})
Template.fetchDetail.parsedInfo = ->
  mod = mods.findOne fetch: @_id
  return if !mod?
  kv = []
  for key, value of mod
    kv.push
      key: key
      value: value
  kv
Template.fetchDetail.events
  "click .delBtn": ->
    bootbox.confirm "Are you sure you want to delete this mod?", (res)=>
      return if !res
      Meteor.call "delMod", @_id, (err, res)->
        if err?
          $.pnotify
            title: "Can't Delete"
            text: err.reason
            type: "error"
        else
          $.pnotify
            title: "Mod Deleted"
            text: "Mod has been deleted."
            type: "success"
  "click .dbBtn": ->
    Meteor.call "flipPlayable", @_id
  "click .udBtn": ->
    Router.go Router.routes["newFetch"].path({id: @_id})
  "click .ftBtn": ->
    Meteor.call "doFetch", @_id, (err, res)->
      if err?
        $.pnotify
          title: "Can't Fetch"
          text: err.reason
          type: "error"
      else
        $.pnotify
          title: "Fetch Started"
          text: "Your fetch has begun."
          type: "success"
