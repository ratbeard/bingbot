irc = require 'irc'

bot = new irc.Client('irc.freenode.net', 'jarjarmuppet',
  debug: true,
  channels: ['#coolkidsusa']
)

bot.addListener 'error', (message) ->
  console.error 'fuk:', message


sayGibberish = ->
  console.log('!!!')
  # hehe, can't get /names to work - mrluc says to try 'join' event
  names = ["darkcypher_bit", "cujojp", "mrluc", "bingbot", "gramps", "f0ster", "pema"]
  name = names[ Math.floor(Math.random() * names.length) ]
  msg = "#{name} in deep doodoo!"
  bot.say '#coolkidsusa', msg


bot.addListener 'message', (from, to, message) ->
  console.log('%s => %s: %s', from, to, message)
  # talk back
  if /jarjarmuppet/.test(message)
    msg = "wesa in deep #doodoo"
    bot.say(to, msg)

  
setInterval sayGibberish, 5 * 60 * 1000


