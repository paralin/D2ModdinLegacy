@winston = Meteor.require 'winston'
@log = new (winston.Logger)(transports: [
  new (winston.transports.Console)(colorize: "true")
])
