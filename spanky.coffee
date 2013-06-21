irc = require 'irc'

bot = new irc.Client('irc.freenode.net', 'spanky',
  debug: true,
  channels: ['#coolkidsusa']
)

bot.addListener 'error', (message) ->
  console.error 'fuk:', message

bot.addListener 'message', (from, to, message) ->
  console.log('%s => %s: %s', from, to, message)

  if message.match /spank (.*)/
    badboi = RegExp.$1
    #bot.say to, "ohh, you da bad boy"
    bot.action to, "spanks #{badboi}"
    bot.say to, "Ohh, you da bad boi ლ(´ڡ`ლ)"


