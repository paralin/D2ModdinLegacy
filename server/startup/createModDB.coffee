###
#Fill the DB with hard-coded mods
###

Meteor.startup ->
  if mods.find().count() is 0
    mods.insert
      name: "rota"
      fullname: "Fight or Flight"
      author: "Jicyphex"
      authorimage: "https://pbs.twimg.com/profile_images/440598138659672064/zz7c2bzE_bigger.png"
      thumbnail: "/thumbs/fof.png"
      spreadimage: "https://s3-us-west-2.amazonaws.com/d2mpimages/fof1.png"
      website: "http://reddit.com/r/Dota2FoF/"
      subtitle: "The first competitive mod in Dota 2 history."
      description: "FoF is based on advanced CTF/CTP elements that redefines the stages of Dota 2; farming is reduced to a minimum, action from the get-go, multiple means of winning and diverse strategies which can be employed. It doesn't matter if you're the one who likes to defend your base, attack the enemies, support your allies, make sure you steal all their flag, or just recover yours, you will always have a place in Fight or Flight."
      features: ["Capture the Flag meets Dota 2.", "Minimal farming, constant action, and diverse strategies.", "Roles for every play style.", "First competitive Dota 2 mod!"]
      public: true
      playable: false
      version: "0.3.8"
      bundlepath: "d2fof.zip"
      requirements:
        d2_gamecount: 50
    mods.insert
      name: "pudgewars"
      fullname: "Pudge Wars"
      author: "Kobb and Aderum"
      authorimage: "/authorimg/pudge.png"
      thumbnail: "/thumbs/pudgewars.jpg"
      spreadimage: "https://s3-us-west-2.amazonaws.com/d2mpimages/pudge.png"
      website: "http://d2pudgewars.com/"
      subtitle: "Remake of the classic WC3 Pudge Wars in Dota 2."
      description: "Pudge Wars is a 5v5 team game. Each player controls a Pudge with only one spell to use: Meat Hook. The teams faces off on a square map divided by an uncrossable river. The first team to get 50 kills wins the game."
      features: ["Every player plays pudge.", "Square map divided by a river.", "Upgrade the damage, range, radius, or speed of your hook.", "First team to 50 kills wins the game!"]
      public: true
      playable: true
      version: "0.12"
      bundlepath: "pudgewars.zip"
      requirements: {} #No requirements
