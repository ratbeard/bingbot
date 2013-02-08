irc = require 'irc'

bot = new irc.Client('irc.freenode.net', 'bragbot',
  debug: true,
  channels: ['#coolkidsusa']
)

bot.addListener 'error', (message) ->
  console.error 'fuk:', message

bot.addListener 'message', (from, to, message) ->
  console.log('%s => %s: %s', from, to, message)

  if Math.floor( Math.random() * 50) == 0
    msg = "Oh yeah #{from}, I've done things like that hundreds of times"
    bot.say to, msg

  if message.match /bragbot/
    bot.say to, "i'm the best"


