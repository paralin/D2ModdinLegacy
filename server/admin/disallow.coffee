#Don't allow new accounts
Accounts.validateNewUser (user)->
  id = user.services.steam.id
  result = HTTP.get "http://d2modd.in/api/getInvitedUserStatus/?key=822956923836&user_id=#{id}"
  parsed = JSON.parse result.content
  parsed.status is 1
