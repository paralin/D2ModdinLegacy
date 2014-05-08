git = Meteor.require "gift"
os = Meteor.require "os"
fs = Meteor.require "fs"
ncp = Async.wrap((Meteor.require "ncp").ncp)
rmdir = Async.wrap(Meteor.require "rimraf")
archiver = Meteor.require "archiver"

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
  #now bundle
  log.info "Creating server bundle #{servname}..."
  clientPath = stage+clientname
  servPath = stage+servname
  fs.unlinkSync servPath if fs.existsSync servPath
  servzip = archiver 'zip'
  stream = fs.createWriteStream servPath
  servzip.pipe stream
  servzip.bulk [{expand: true, cwd: stage, src: fetch.info.name+'/**'}]
  servzip.finalize()
  log.info "Creating client bundle #{clientname}..."
  clizip = archiver 'zip'
  stream = fs.createWriteStream clientPath
  clizip.pipe stream
  clizip.bulk [{expand: true, cwd: stagem, src: '**'}]
  clizip.finalize()
  log.info "Bundles complete, uploading to AWS..."
  putObject servname, fs.readFileSync servPath
  putObject clientname, fs.readFileSync clientPath
  log.info "Files uploaded, cleaning up..."
  rmdir stagem
  fs.unlinkSync servPath
  fs.unlinkSync clientPath

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
