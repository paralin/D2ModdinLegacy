defaultFetch =
  git: ""
  ref: ""
  name: ""
matchesFetch = null
gitRegex = new RegExp "((git|ssh|http(s)?)|(git@[\\w.]+))(:(//)?)([\\w.@\\:/-~]+)(.git)(/)?"
Meteor.startup ->
  matchesFetch = _.matches defaultFetch
Meteor.methods
  'doFetch': (id)->
    user = Meteor.users.findOne {_id: @userId}
    if !AuthManager.userIsInRole @userId, "developer"
      throw new Meteor.Error 403, "You are not a developer."
    fetch = modfetch.findOne
      _id: id
      user: @userId
    if !fetch?
      throw new Meteor.Error 404, "Can't find that fetch."
    if fetch.status isnt 0
      throw new Meteor.Error 403, "The server is already working on this fetch."
    @unblock()
    modfetch.update {_id: id}, {$set: {status: 1, error: "Fetching repository..."}}
    fmod = fetchMod fetch
    fmod._id = id
    fmod.user = @userId
    fmod.steamid = user.services.steam.id
    if fmod.error?
      modfetch.update {_id: id}, {$set: {status: 0, error: "Problem fetching: #{fmod.error}"}}
      return
    modfetch.update {_id: id}, {$set: {error: "Bundling mod..."}}
    bundleMod fmod
    res = registerMod fmod
    if res? && res.error?
      modfetch.update {_id: id}, {$set: {status: 0, error: "Problem fetching: #{res.error}"}}
      return
    modfetch.update {_id: id}, {$set: {status: 0, error: "Deployed successfully."}}
  'updateModFetch': (id,fetch)->
    user = Meteor.users.findOne {_id: @userId}
    if !AuthManager.userIsInRole @userId, "developer"
      throw new Meteor.Error 403, "You are not a developer."
    exist = modfetch.findOne {_id: id, user: @userId}
    if !exist?
      throw new Meteor.Error 404, "Can't find that mod fetch."
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
    fetch.user = exist.user
    fetch.error = "You have not performed the initial fetch after the update."
    fetch._id = id
    clearExistingRepo id
    modfetch.update {_id: id}, fetch
  'flipPlayable': (id)->
    user = Meteor.users.findOne {_id: @userId}
    if !AuthManager.userIsInRole @userId, "developer"
      throw new Meteor.Error 403, "You are not a developer."
    fetch = modfetch.findOne({_id: id})
    if !fetch?
      throw new Meteor.Error 404, "Can't find that mod."
    mod = mods.findOne(fetch: id)
    if mod?
      mods.update({_id: mod._id}, {$set: {playable: !mod.playable}})
  'delMod': (id)->
    user = Meteor.users.findOne {_id: @userId}
    if !AuthManager.userIsInRole @userId, "developer"
      throw new Meteor.Error 403, "You are not a developer."
    fetch = modfetch.findOne({_id: id})
    if !fetch?
      throw new Meteor.Error 404, "Can't find that mod."
    clearExistingRepo id
    modfetch.remove({_id: id})
    ServerAddons.remove {fetch: id}
    mod = mods.findOne(fetch: id)
    if mod?
      mods.remove({fetch: id})
      deleteObject mod.bundle
      deleteObject "serv_"+mod.bundle
    true
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
