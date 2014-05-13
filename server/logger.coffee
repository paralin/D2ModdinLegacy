@winston = Meteor.require 'winston'
@log = new (winston.Logger)(transports: [
  new (winston.transports.Console)(colorize: "true")
  new (winston.transports.File)({filename: '2moddin.log'})
])
