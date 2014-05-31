Meteor.publish "clientProgram", ->
  if !@userId?
    @stop()
  clients.findFaster {_id: @userId}, {limit: 1}
