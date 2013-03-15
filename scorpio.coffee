irc = require 'irc'

bot = new irc.Client('irc.freenode.net', 'scorpio',
  debug: true,
  channels: ['#coolkidsusa']
)

# Store scores.  TODO - store in a heroku cloud (thanks @cujojp for idea)
scores = { dubs: 1000000 }

bot.addListener 'error', (message) ->
  console.error 'fuk:', message


bot.addListener 'message', (from, to, message) ->
  console.log('%s => %s: %s', from, to, message)

  if match = message.match(/([+-]\d+)\s+(\S+)/)
    [_, score, user] = match
    score = parseInt(score)
    scores[user] ||= 0

    # Dubs is invincible
    if user == 'dubs'
      scores[user] += Math.abs(score)
    # Can't award points to yourself unless they're negative.  +1 @pennig
    else if user == from and score > 0
      scores[user] -= 100
    else
      scores[user] += score

    # clean out 0 scores
    delete scores[user] if scores[user] == 0

    if user == 'jarjarmuppet'
      bot.say to, "bing what about jarjarmuppet"

  else if match = message.match /score (\S+)/
    user = match[1]
    score = scores[user] || 'no'
    msg = "#{user} has #{score} points"
    bot.say to, msg
    
  else if message.match /whats the score/
    msg = for name, score of scores
      "#{name} has #{score} points"
    msg = msg.join(", ")
    bot.say to, msg

