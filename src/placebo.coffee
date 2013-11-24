# Require dependencies
axon = require 'axon'

# Define private variables
socket = null
timers = {}
config = {}
levels = {
  log     : 0
  debug   : 0
  system  : 1
  info    : 2
  warn    : 3
  warning : 3
  error   : 4
}

# Configure default configuration
exports.configure = (settings) ->
  for key, value of settings
    config[key] = value

# Connect to Panacea server
exports.connect = (port, host, fn) ->

  socket = axon.socket 'push'

  socket.format 'json'
  socket.connect port, host, fn

# Send message to server
send = exports.send = (message, options) ->

  if socket is null
    throw new Error "Placebo: service not connected"

  log =
    message : message
    level   : options.level    ? config.level
    color   : options.color   or config.color
    time    : options.time    or Date.now()
    server  : options.server  or config.server
    process : options.process or config.process

  # Map level name for numeric ID
  if log.level of levels
    log.level = levels[log.level]

  # Send message to Panacea server
  socket.send log

# Provide syntax sugar to send function
sugar = (level, message, options = {}) ->
    options.level = level
    send message, options

for method, level of levels
  exports[method] = sugar.bind null, level

# Provide timing logs
time = exports.time = (flag) ->

  if timers[flag]

    time    = Date.now() - timers[flag] / 1000
    message = [flag, ': ', time, 's'].join ""

    send message, { level : -1 }

    delete timers[flag]

  else
    timers[flag] = Date.now()

