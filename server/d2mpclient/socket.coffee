qopu = (user, message)->
  qop user._id, message
qop = (clientid, message)->
  return if !clientid? || !message?
  CMsgQueue.insert
    id: clientid
    msg: message

@setMod = (client, mod)->
  qopu client, "setmod:#{mod}"
@dspectate = (client, addr)->
  qopu client, "dspectate:#{addr}"
@launchDota = (client)->
  qopu client, "launchdota"
@dconnect = (client, addr)->
  qopu client, "dconnect:#{addr}"
@installMod = (client, mod)->
  command = "installmod:"+mod.name+"="+mod.version+":"+generateModDownloadURL(mod)
  qop client, command
@shutdownClient = (userId)->
  qop userId, "close"
@uninstallClient = (userId)->
  qop userId, "uninstall"
