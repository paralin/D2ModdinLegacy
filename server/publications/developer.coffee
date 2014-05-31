Meteor.smartPublish "devData", ->
  if !@userId? || !AuthManager.userIsInRole(@userId, "developer")
    return @stop()
  @addDependency "modfetch", "_id", (fetch)->
    mods.findFaster {fetch: fetch._id}
  if AuthManager.userIsInRole @userId, "admin"
    modfetch.findFaster({})
  else
    modfetch.findFaster({user: @userId})
