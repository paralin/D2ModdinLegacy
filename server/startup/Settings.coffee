Meteor.startup ->
  if !Settings.findOne({type: "homebg"})?
    Settings.insert
      type: "homebg"
      image: "https://s3-us-west-2.amazonaws.com/d2mpimages/homeback.jpg"
