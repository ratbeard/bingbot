irc = require 'irc'

bot = new irc.Client('irc.freenode.net', 'scorpio',
  debug: true,
  channels: ['#coolkidsusa']
)

scores = {}

bot.addListener 'error', (message) ->
  console.error 'fuk:', message


bot.addListener 'message', (from, to, message) ->
  console.log('%s => %s: %s', from, to, message)

  if message.match(/([+-]\d+)\s+(\w+)/)
    [score, user] = [RegExp.$1, RegExp.$2]
    score = parseInt(score)
    console.log(score, user)

    scores[user] ||= 0
    total = scores[user] += score

    console.log(scores)

    msg = "#{user} has #{total} points"
    bot.say(to, msg)

    
  else if message.match /whats the score/
    msg = for name, score of scores
      "#{name} has #{score} points"
      
    bot.say to, msg.join(", ")

  # talk back
  #if /jarjarmuppet/.test(message)
    #msg = "wesa in deep #doodoo"
    #bot.say(to, msg)




