phantomjs = Meteor.require 'phantomjs'
path = Meteor.require 'path'
process.env.PATH += ":#{path.dirname(phantomjs.path)}"
