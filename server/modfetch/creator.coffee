defaultFetch =
  git: ""
  ref: ""
  name: ""
matchesFetch = null
gitRegex = new RegExp "((git|ssh|http(s)?)|(git@[\\w.]+))(:(//)?)([\\w.@\\:/-~]+)(.git)(/)?"
Meteor.startup ->
  matchesFetch = _.matches defaultFetch
Meteor.methods
  'createModFetch': (fetch)->
    user = Meteor.users.findOne {_id: @userId}
    if !AuthManager.userIsInRole @userId, "developer"
      throw new Meteor.Error 403, "You are not a developer."
    if !matchesFetch fetch
      throw new Meteor.Error 403, "Your fetch info is invalid."
    if !gitRegex.test fetch.git
      throw new Meteor.Error 403, "Your git URL is not valid."
    if fetch.name.length > 30 || fetch.name.length < 4
      throw new Meteor.Error 403, "Your name must be 4 < characters < 30."
    if fetch.ref.length > 25 || fetch.ref.length < 3
      throw new Meteor.Error 403, "Your ref must be 25 > characters > 3."
    fetch = _.pick fetch, _.keys defaultFetch
    fetch.status = 0
    fetch.error = "You have not performed the initial fetch yet."
    fetch.user = @userId
    modfetch.insert fetch
