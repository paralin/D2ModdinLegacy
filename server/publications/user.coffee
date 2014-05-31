Meteor.publish "userData", ->
  Meteor.users.find {_id: @userId}, {fields: {
    createdAt: 0
    status: 0
  }}
