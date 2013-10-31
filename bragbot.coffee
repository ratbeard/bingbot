irc = require 'irc'

bot = new irc.Client('irc.freenode.net', 'bangbot',
  debug: true,
  channels: ['#coolkidsusa']
)

bot.addListener 'error', (message) ->
  console.error 'fuk:', message

bot.addListener 'message', (from, to, message) ->
  console.log('%s => %s: %s', from, to, message)

  randomInt = (low, high) ->
    return low + Math.floor(Math.random() * (high - low))
  
  verb = [
    'ravaged',
    'grilled',
    'attacked',
    'raped',
    'brutally fucked',
    'damaged',
    'toyed with',
    'teased'
  ]

  noun = [
    'Ford F350 with 12 burners',
    'Elevator Shaft',
    'Desk',
    'Starbucks Table',
    '@theRealWJJs couch',
    'Porche 911s hood',
    'Swamp Marsh'
  ]

  thing = [
    'Snake',
    'Duncan',
    '@theRealWJJ',
    'Homeless Guy',
    'School Teacher',
    'Children',
    'Camp Counselor'
  ]

  getVerb = ->
    number = randomInt(0, verb.length)
    return verb[number]

  getNoun = ->
    number = randomInt(0, noun.length)
    return noun[number]

  getThing = ->
    number = randomInt(0, thing.length)
    return thing[number]

  if Math.floor( Math.random() * 50) == 0
    msg = "camsnap jlo gets #{getVerb()} on #{getNoun()} by #{getThing()}"
    bot.say to, msg

  if message.match /bangbot/
    msg = "camsnap jlo gets #{getVerb()} on #{getNoun()} by #{getThing()}"
    bot.say to, msg
