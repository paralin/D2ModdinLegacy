Template.developer.fetches = ->
  cursor = modfetch.find()
  if cursor.count() is 0
    return null
  cursor
