###
#Fill the DB with hard-coded mods
###

Meteor.startup ->
  if mods.find().count() is 0
    mods.insert
      name: "fof"
      fullname: "Fight or Flight"
      author: "Jicyphex"
      authorimage: "https://pbs.twimg.com/profile_images/440598138659672064/zz7c2bzE_bigger.png"
      thumbnail: "/thumbs/fof.png"
      spreadimage: "/spread/fof1.png"
      website: "http://reddit.com/r/Dota2FoF/"
      subtitle: "The first competitive mod in Dota 2 history."
      description: "FoF is based on advanced CTF/CTP elements that redefines the stages of Dota 2; farming is reduced to a minimum, action from the get-go, multiple means of winning and diverse strategies which can be employed. It doesn't matter if you're the one who likes to defend your base, attack the enemies, support your allies, make sure you steal all their flag, or just recover yours, you will always have a place in Fight or Flight."
      features: ["Capture the Flag meets Dota 2.", "Minimal farming, constant action, and diverse strategies.", "Roles for every play style.", "First competitive Dota 2 mod!"]
      public: true
      playable: false
      bundlepath: "d2fof.zip"
      requirements:
        d2_gamecount: 50
