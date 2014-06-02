@lobbies = new Meteor.Collection null
@lobbyList = new Meteor.Collection null

colls = {
  lobbies: lobbies,
  publicLobbies: lobbyList
}

@lobbyServConn = new WebSocket 'ws://10.0.1.3:4000/browser'

window.onbeforeunload = ->
  lobbyServConn.onclose = null
  lobbyServConn.close()

handleMsg = (msg)->
  data = JSON.parse msg
  console.log msg
  console.log data
  switch data.msg
    when "auth"
      if data.status
        $.pnotify
          title: "Authenticated"
          text: "You are connected to the lobby server."
          type: "success"
      else
        $.pnotify
          title: "Deauthenticated"
          text: "You are no longer authed with the lobby server."
          type: "error"
    when "colupd"
      for upd in data.ops
        coll = colls[upd._c]
        op = upd._o
        delete upd["_o"]
        delete upd["_c"]
        switch op
          when "insert"
            coll.insert upd
          when "update"
            id = upd._id
            delete upd["_id"]
            coll.update {_id: id}, {$set: upd}
          when "remove"
            coll.remove upd

lobbyServConn.onmessage = (e)->
  handleMsg e.data

send = (data)->
  lobbyServConn.send JSON.stringify data

sendAuth = (user)->
  if !user?
    send id: "deauth"
  else
    return if !user.services? || !user.services.resume?
    send
      id: "auth"
      uid: Meteor.userId()
      key: _.last user.services.resume.loginTokens

setup = false
lobbyServConn.onclose = ->
  $.pnotify
    title: "Disconnected"
    text: "Disconnected from the lobby server."
    type: "error"
  lobbies.remove({})
  lobbyList.remove({})
lobbyServConn.onopen = ->
  if setup
    return sendAuth()
  setup = true
  Deps.autorun ->
    user = Meteor.user()
    sendAuth user
