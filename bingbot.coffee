irc = require 'irc'


bot = new irc.Client('irc.freenode.net', 'bingbot', {
  debug: true,
  channels: ['#coolkidsusa']
})

bot.addListener 'error', (message) ->
  console.error 'fuk:', message

bot.addListener 'message', (from, to, message) ->
  console.log('%s => %s: %s', from, to, message)

  if /bing\s+(.*)/.test(message)
    query = encodeURIComponent(RegExp.$1)
    url = "http://www.bing.com/search?q=#{query}"
    console.log(url)

    msg = "You asked, I answered!  Heres those results you wanted"
    msg += ":\n"
    msg += "    #{url}"
    bot.say(to, msg)

  # talk back
  else if /bingbot/.test(message)
    msg = message.replace(/bingbot/g, from)
    bot.say(to, msg)


  



