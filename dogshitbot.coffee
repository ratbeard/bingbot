irc = require 'irc'

bot = new irc.Client('irc.freenode.net', 'dogshitbot',
  debug: true,
  channels: ['#coolkidsusa']
)

bot.addListener 'error', (message) ->
  console.error 'fuk:', message

bot.addListener 'message', (from, to, message) ->
  console.log('%s => %s: %s', from, to, message)
