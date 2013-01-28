irc = require 'irc'

bot = new irc.Client('irc.freenode.net', 'scorpio',
  debug: true,
  channels: ['#coolkidsusa']
)

# Store scores.  TODO - store in a heroku cloud (thanks @cujojp for idea)
scores = {}

bot.addListener 'error', (message) ->
  console.error 'fuk:', message


bot.addListener 'message', (from, to, message) ->
  console.log('%s => %s: %s', from, to, message)

  if message.match(/([+-]\d+)\s+(\w+)/)
    [score, user] = [RegExp.$1, RegExp.$2]
    score = parseInt(score)
    scores[user] ||= 0
    scores[user] += score
    delete scores[user] if scores[user] == 0

    if user == 'jarjarmuppet'
      bot.say to, "bing what about jarjarmuppet"

  else if message.match /score (\w+)/
    user = RegExp.$1
    msg = "#{user} has #{scores[user]} points"
    bot.say to, msg
    
  else if message.match /whats the score/
    msg = for name, score of scores
      "#{name} has #{score} points"
    msg = msg.join(", ")
    bot.say to, msg

