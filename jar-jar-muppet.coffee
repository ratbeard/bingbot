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
  names = [
    "darkcypher_bit"
    "cujojp"
    "mrluc"
    "bingbot"
    "gramps"
    "f0ster"
    "pema"
    "unhipglint"
    "dubs"
    "griswold"
    "pennig"
  ]
  name = names[ Math.floor(Math.random() * names.length) ]
  directMessages = [
    "hey yo, daddy, #{name}.  meesa back!"
    "#{name}, hello boyo!"
    "#{name}, watch out for da mackaneeks!"
    "#{name}, in deep doodoo!"
    "#{name}, I don't know. mesa day startin pretty okee-day with a brisky morning munchy, then boom! gettin very scared and grabbin that jedi and pow!"
    "#{name}, ooh mooey mooey i love you!"
  ]
  msg = directMessages[ Math.floor(Math.random() * directMessages.length) ]
  bot.say '#coolkidsusa', msg


bot.addListener 'message', (from, to, message) ->
  console.log('%s => %s: %s', from, to, message)  
  # talk back
  if /jarjarmuppet/.test(message)
    globalMessages = [
      "wesa got a grand army. that's why you no liking us meesa thinks."
      "yipe! how wude!"
      "it's a longo taleo buta small part of it would be mesa... clumsy."
      "yud say boom de gasser, den crashin der bosses heyblibber, den banished."
    ]
    msg = "wesa in deep #doodoo"
    bot.say(to, globalMessages[ Math.floor(Math.random() * globalMessages.length) ])

  
setInterval sayGibberish, 5 * 60 * 1000 * (Math.random() * 15)


