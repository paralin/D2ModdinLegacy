@lobbies = new Meteor.Collection null
@lobbyList = new Meteor.Collection null

colls = {
  lobbies: lobbies,
  publicLobbies: lobbyList
}
hasConnected = true

Meteor.startup ->
  @lobbyServConn = null
  @sendAuth = (user)->
    if !user?
      if lobbyServConn?
        lobbyServConn.close()
        lobbyServConn = null
    else
      return if !user.services? || !user.services.resume?
      if !lobbyServConn?
        @lobbyServConn = new XSockets.WebSocket 'ws://10.0.1.3:4000/Browser'
        setupBinds()
      else
        send
          id: "auth"
          uid: Meteor.userId()
          key: _.last user.services.resume.loginTokens

  Deps.autorun ->
    user = Meteor.user()
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
    send data

  handleMsg = (data)->
    switch data.msg
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
    lobbyServConn.on 'auth', (data)->
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
    lobbyServConn.on 'lobby', (msg)->
      handleMsg msg
    lobbyServConn.onclose = ->
      lobbyServConn = null
      sendAuth(Meteor.user())
      return if !hasConnected
      lobbyList.remove({})
      hasConnected = false
      $.pnotify
        title: "Disconnected"
        text: "Disconnected from the lobby server."
        type: "error"
    lobbyServConn.onopen = (clientInfo)->
      hasConnected = true
      console.log "connected"
      $.pnotify
        title: "Connected"
        text: "Connected to the lobby server."
        type: "success"
      lobbies.remove({})
      send
        id: "auth"
        uid: Meteor.userId()
        key: _.last Meteor.user().services.resume.loginTokens

  send = (data)->
    return if !lobbyServConn?
    lobbyServConn.publish 'data', data
