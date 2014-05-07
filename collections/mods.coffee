### Current Mods (ephemeral) ####
#new field: fetch - ID in modfetch
@mods = new Meteor.Collection "mods"

### Publish Database (fetch mods) ###
#Stores information about the source of the mods (for the compile system)
#
#name: Nice name used for the publish UI
#git: git url for the repo
#ref: ref to checkout
#status: 0=Unfetched, 1=Fetching, 2=OK, 3=Problems
#error: error message (if any)
#user: userid of developer
@modfetch = new Meteor.Collection "modfetch"
