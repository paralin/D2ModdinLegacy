Meteor.publish "userData", ->
  Meteor.users.find
    _id: @userId
#  ,
#    fields:
#      services: 1
