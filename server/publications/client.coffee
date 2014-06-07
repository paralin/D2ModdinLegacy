Meteor.publish "clientProgram", ->
  if !@userId?
    return @stop()
  clients.find {_id: @userId}, {limit: 1}
