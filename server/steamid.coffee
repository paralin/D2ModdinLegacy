@steamidconvert = Meteor.require "steamidconvert"
@bignumber = Meteor.require "bignumber.js"
@toSteamID32 = (id)->
  sids = (steamidconvert.convertToText id).split ":"
  id = parseInt sids[2]
  id*(2+parseInt(sids[1]))+1
@toSteamID64 = (id)->
  bignumber(id).plus('76561197960265728')+""
