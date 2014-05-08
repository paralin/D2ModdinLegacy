Fiber = Meteor.require "fibers"
S3 = Meteor.require 's3'
knox = Meteor.require 'knox'
kn = knox.createClient
  'key'     : "AKIAJ4QROL3BSAMJTI7Q",
  'secret' : "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",
  'bucket': 'd2mpclient'
s3 = S3.fromKnox kn
###
Meteor.startup ->
  s3.listBuckets {}, (err, data)->
    console.log "=== buckets ==="
    if err?
      console.log "Error loading buckets: "+err
    else if data?
      bucketFound = false
      for bucket, i in data.Buckets
        console.log "  --> "+bucket.Name
###
headers =
  'Content-Type': 'application/octet-stream'
@upload = (lfile, rfile)->
  Async.runSync (done)->
    uploader = s3.upload lfile, rfile, headers
    uploader.on 'error', (err)->
      done(err)
    uploader.on 'end', (url)->
      done(null, url)


@generateModDownloadURL = (mod)->
  getBundleDownloadURL mod.bundle
@getBundleDownloadURL = (file)->
  expiration = new Date()
  expiration.setMinutes(expiration.getMinutes() + 5)
  kn.signedUrl(file, expiration)
