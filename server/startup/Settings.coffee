Meteor.startup ->
  if !Settings.findOne({type: "homebg"})?
    Settings.insert
      type: "homebg"
      image: "/images/homeback.jpg"
