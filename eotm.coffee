irc = require 'irc'

bot = new irc.Client('irc.freenode.net', 'EOTM_bot',
  debug: true,
  channels: ['#coolkidsusa']
)

# Store scores.  TODO - store in a heroku cloud (thanks @cujojp for idea)
scores = { dubs: 1000000 }

bot.addListener 'error', (message) ->
  console.error 'fuk:', message


bot.addListener 'message', (from, to, message) ->
  console.log('%s => %s: %s', from, to, message)

  if from == 'darkcypher_bit'
    bot.say to, 'Hear Ye, Hear Ye.  The EOTM speaketh, and his word is law'

