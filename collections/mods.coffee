### MOD OBJECT ####
# PUBLIC
#   -> name -> "fof"
#   -> fullname -> "Fight or Flight"
#   -> author -> "Jicyphex"
#   -> authorimage -> "http://media.steampowered.com/steamcommunity/public/images/avatars/db/dbc96a9a1e22bec0d8eb600df2ed0de158fb5564_full.jpg"
#   -> spreadimage -> "/spread/fof1.png"
#   -> website -> "http://www.reddit.com/r/Dota2FoF/"
#   -> subtitle -> "The first competitive mod in Dota 2 history."
#   -> description -> "
#     FoF is based on advanced CTF/CTP elements that redefines the stages of Dota 2; farming is reduced to a minimum, action from the get-go, multiple means of winning and diverse strategies which can be employed. It doesn't matter if you're the one who likes to defend your base, attack the enemies, support your allies, make sure you steal all their flag, or just recover yours, you will always have a place in Fight or Flight.
#   -> public -> true
#   -> playable -> false (for now)
# PRIVATE
#   -> bundlepath: (info on S3 bucket) - if null then no local files
#   -> version: mod version code
#   -> requirements:
#     {
#       "d2_gamecount": 50
#     }
@mods = new Meteor.Collection "mods"
