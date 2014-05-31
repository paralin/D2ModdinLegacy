Meteor.publish "userData", ->
  Meteor.users.findFaster {_id: @userId}, {fields: {
    createdAt: 0
    status: 0
  }}
