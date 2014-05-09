git = Meteor.require "gift"
os = Meteor.require "os"
fs = Meteor.require "fs"
ncp = Async.wrap((Meteor.require "ncp").ncp)
rmdir = Async.wrap(Meteor.require "rimraf")
archiver = Meteor.require "archiver"
Fiber = Meteor.require "fibers"

Meteor.startup ->
  modfetch.update {status: 1}, {$set: {status: 0, error: "Your fetch was interrupted. Please try it again."}}, {multi: true}
# Helper Methods #
mkdirp = (path)->
  fs.mkdir path, (e)->
    return

rootDir = "#{os.tmpdir()}/d2mprepo/"

cloneOrPull = (name, url, branch)->
  if !fs.existsSync(rootDir+name+"/")
    cloneRepo name, url
  else
    rep = git rootDir+name+"/"
    Async.runSync (done)->
      rep.git "fetch", {}, ["--all"], (err, stdout, stderr)->
        if err?
          log.info "Problem fetching: "+stderr
        log.info "checking out #{branch}"
        rep.git "checkout", {}, [branch], (err, stdout, stderr)->
          rep.git "pull", {}, [], (errb, stdoutb, stderrb)->
            done((if err? then stderr else null), stdout)
        #rep.git "pull", {}, ["", ""], (err, stdout, stderr) ->
        #  done((if err? then stderr else null), stdout)

cloneRepo = (name, url)->
  Async.runSync (done)->
    git.clone url, rootDir+name+"/", (err, repo)->
      done(err, repo)

# Procedures #
defaultMod =
  name: ""
  fullname: ""
  version: ""
  author: ""
  authorimage: ""
  thumbnail: ""
  spreadimage: ""
  website: ""
  subtitle: ""
  description: ""
  features: []
  public: false
  playable: false
  requirements: {}
_.matches = (attrs) ->
  (obj) ->
    return _.isEmpty(attrs)  unless obj?
    return true  if obj is attrs
    for key of attrs
      continue
    true
isValidMod = _.matches defaultMod

@registerMod = (fetch)->
  info = fetch.info
  info = _.pick info, _.keys defaultMod
  return {error: "You are missing one or more fields in info.json."} if !isValidMod info
  info.bundle = info.name+".zip"
  info.fetch = fetch._id
  info.user = fetch.user
  servAddon =
    name: info.name
    version: info.version
    bundle: "serv_#{info.name}.zip"
    fetch: fetch._id
  mods.remove {name: info.name}
  ServerAddons.remove {name: info.name}
  mods.insert info
  ServerAddons.insert servAddon
  log.info "Registered mod #{info.name} in the database."

@bundleMod = (fetch)->
  Async.runSync (done)->
    log.info "Bundling mod..."
    clientname = fetch.info.name+".zip"
    servname = "serv_"+clientname
    #Copy all but .git to a staging dir
    stage = "#{os.tmpdir()}/d2mpstaging/"
    mkdirp stage
    stagem = stage+fetch.info.name+"/"
    rmdir stagem if fs.existsSync stagem
    mkdirp stagem
    ncp fetch.path, stagem
    #files in place, clean
    rmdir stagem+".git/"
    fs.unlinkSync stagem+'info.json'
    addonInfo = generateAddonInfo fetch.info, fetch.steamid
    fs.writeFileSync stagem+"addoninfo.txt", addonInfo
    console.log addonInfo
    #now bundle
    log.info "Creating server bundle #{servname}..."
    clientPath = stage+clientname
    servPath = stage+servname
    fs.unlinkSync servPath if fs.existsSync servPath
    servzip = archiver 'zip'
    servstream = fs.createWriteStream servPath
    servzip.pipe servstream
    servzip.bulk [{expand: true, cwd: stage, src: fetch.info.name+'/**'}]
    clizip = archiver 'zip'
    finished = ->
      log.info "Bundles complete, uploading to AWS..."
      res = upload servPath, servname
      console.log res
      res = upload clientPath, clientname
      console.log res
      log.info "Files uploaded, cleaning up..."
      rmdir stagem
      fs.unlinkSync servPath
      fs.unlinkSync clientPath
      new Fiber(->
        done(null, null)
      ).run()
    servstream.on 'finish', new Fiber(->
      log.info "Creating client bundle #{clientname}..."
      stream = fs.createWriteStream clientPath
      rmdir stagem+"scripts/vscripts/"
      clizip.pipe stream
      clizip.bulk [{expand: true, cwd: stagem, src: '**'}]
      clizip.finalize()
      stream.on 'finish', new Fiber(finished).run
    ).run
    servzip.finalize()

@clearExistingRepo = (id)->
  rmdir rootDir+id+"/"

@fetchAndBundle = (fmod)->
  fetch = fetchMod fmod
  return fetch if fetch.error?
  bundleMod fetch
  fetch

# fmod: modfetch object
@fetchMod = (fmod)->
  res = cloneOrPull fmod._id, fmod.git, fmod.ref
  return res if res.error?
  path = rootDir+fmod._id+"/"
  infoP = path+"info.json"
  info = null
  return {error: "There is no info.json in your repository."} if !fs.existsSync(infoP)
  try
    info = JSON.parse fs.readFileSync infoP
  catch e
    return {error: "Issue parsing info.json #{e}"}
  {path: path, info: info}
generateAddonInfo = (info, steamid)->
  """
  \"AddonInfo\"
  {
       addonSteamAppID 186
       addontitle      \"#{info.fullname}\"
       addonversion    #{info.version}
       addontagline    \"#{info.subtitle}\"
       addonauthor     \"#{info.author}\"
       addonSteamGroupName \"D2Moddin\"
       addonauthorSteamID  \"#{steamid}\"
       addonContent_Campaign 0
       addonURL0       \"#{info.website}\"
       addonDescription \"#{info.subtitle}\"
  }
  """
