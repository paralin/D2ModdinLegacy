setupFilters = (stream, id)->
  perm = (eventName)->
    return false if !@userId?
    lobby = findUserLobby(@userId)
    return false if !lobby? or lobby._id isnt id
    true
  stream.permissions.write perm
  stream.permissions.read perm
  stream.addFilter (eventName, args) ->
    return if !@userId?
    if eventName is "message"
      user = Meteor.users.findOne _id: @userId
      return if args[0] is ""
      args[0] = user.profile.name+": "+args[0]
      console.log "chat message ("+id+"): "+args[0]
    return args
    
streams = {}
Meteor.startup ->
  lobbies.find({status: {$lt: 4}}, {fields: {status: 1}}).observeChanges
    added: (id, fields)->
      #create the chat stream
      stream = new Meteor.Stream(id)
      streams[id] = stream
      setupFilters(stream, id)
    removed: (id)->
      delete streams[id]
