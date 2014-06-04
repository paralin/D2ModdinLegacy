@lobbies = new Meteor.Collection null
@lobbyList = new Meteor.Collection null

colls = {
  lobbies: lobbies,
  publicLobbies: lobbyList
}

Meteor.startup ->
  @lobbyServConn = null
  @sendAuth = (user)->
    if !user?
      if lobbyServConn?
        lobbyServConn.close()
        lobbyServConn = null
    else
      return if !user.services? || !user.services.resume?
      lobbyServConn = new ReconnectingWebSocket 'ws://ddp2.d2modd.in:4000/browser'
      setupBinds()
      send
        id: "auth"
        uid: Meteor.userId()
        key: _.last user.services.resume.loginTokens

  Deps.autorun ->
    user = Meteor.user()
    return if !user?
    sendAuth user

  window.onbeforeunload = ->
    return if !lobbyServConn?
    lobbyServConn.onclose = ()->
    lobbyServConn.close()

  @callMethod = (name, args)->
    return if !lobbyServConn?
    data =
      id: name
      req: args
    lobbyServConn.send JSON.stringify data

  handleMsg = (msg)->
    data = JSON.parse msg
    switch data.msg
      when "auth"
        if data.status
          $.pnotify
            title: "Authenticated"
            text: "You are connected to the lobby server."
            type: "success"
        else
          lobbies.remove {}
          $.pnotify
            title: "Deauthenticated"
            text: "You are no longer authed with the lobby server."
            type: "error"
      when "error"
        $.pnotify
          title: "Lobby Error"
          text: data.reason
          type: "error"
      when "chat"
        pushChatMessage data.message
      when "modneeded"
        Router.go "/install/#{data.name}"
      when "installres"
        Session.set "isDownMod", false
        if data.success
          Router.go "/lobbies"
          $.pnotify
            title: "Mod Installed"
            text: "The mod has been downloaded successfully."
            type: "success"
        else
          $.pnotify
            title: "Download Problem"
            text: data.reason
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

  setupBinds = ->
    lobbyServConn.onmessage = (e)->
      handleMsg e.data
    lobbyServConn.onclose = ->
      $.pnotify
        title: "Disconnected"
        text: "Disconnected from the lobby server."
        type: "error"
      lobbyList.remove({})
    lobbyServConn.onopen = ->
      $.pnotify
        title: "Connected"
        text: "Connected to the lobby server."
        type: "success"
      lobbies.remove({})
      return sendAuth(Meteor.user())

  send = (data)->
    return if !lobbyServConn?
    lobbyServConn.send JSON.stringify data

