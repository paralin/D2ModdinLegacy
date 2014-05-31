Meteor.publish "clientProgram", ->
  if !@userId?
    @stop()
  clients.find {_id: @userId}, {limit: 1}
