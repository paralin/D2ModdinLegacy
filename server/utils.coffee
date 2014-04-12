@checkAdmin = (userId)->
  return userId? && AuthManager.userIsInRole userId, "admin"
