Meteor.smartPublish "devData", ->
  if !@userId? || !AuthManager.userIsInRole(@userId, "developer")
    return @stop()
  @addDependency "modfetch", "_id", (fetch)->
    mods.find {fetch: fetch._id}
  if AuthManager.userIsInRole @userId, "admin"
    modfetch.find({})
  else
    modfetch.find({user: @userId})
