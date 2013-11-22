# Require dependencies
axon = require 'axon'

# Define private variables
socket = null
timers = {}
config = {}

# Configure default configuration
exports.configure = (settings) ->
  for key, value of settings
    config[key] = value

  return this

# Connect to Panacea server
exports.connect = (port, host, fn) ->

  socket = axon.socket 'push'

  socket.format 'json'
  socket.connect port, host, fn

  return this

# Send message to server
exports.send = send = (message, options) ->

  if socket is null
    throw new Error "Placebo: service not connected"

  log =
    message : message
    level   : options.level   or config.level
    color   : options.color   or config.color
    time    : options.time    or Date.now()
    server  : options.server  or config.server
    process : options.process or config.process

  # console.log log
  socket.send log

  return this

# Provide syntax sugar to send function
for method, level of { debug: 0, system: 1, info: 2, warning: 3, error: 4 }
  exports[method] = (message, options = {}) ->
    options.level = level
    send message, options

# Provide timing logs
exports.time = time = (flag) ->

  if timers[flag]

    time    = Date.now() - timers[flag] / 1000
    message = [flag, ': ', time, 's'].join ""

    send message, { level : -1 }

    delete timers[flag]

  else
    timers[flag] = Date.now()

  return this

