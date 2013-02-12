irc = require 'irc'
http = require 'http'

# Return a url for a random image found in bing image search
getImage = (query, callback) ->
  url = "http://www.bing.com/images/search?q=#{query}"

  http.get url, (res)->
    html = ''
    res.setEncoding('utf8')
    res.on 'data', (chunk) ->
      #console.log(chunk)
      #console.log('xxxxxx')
      html += chunk
    res.on 'end', ->
      #console.log(html)
      matches = html.match(/<img src="http(.*?)"/g)
      #console.log(matches)
      if randomMatch = sample(matches)
        url = randomMatch.split('"')[1]
        url = url.replace(/&amp;/g, '&')
        url += '.jpg' # trick limechat!
        callback(url)
      else
        callback(null)

# GOOOGLE
getImage = (query, callback) ->
  url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=1&q=#{query}"
  http.get url, (res) ->
    html = ''
    res.setEncoding('utf8')
    res.on 'data', (chunk) ->
      html += chunk
    res.on 'end', ->
      data = JSON.parse(html)
      img = data.responseData?.results?[0].url
      callback(img)
    

#getImage 'cats', (img) -> console.log img
#return

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

    msg = " ( ͡° ͜ʖ ͡°) You asked, I answered!  Heres those results you wanted: "
    msg += "  #{url}"
    bot.say(to, msg)

  else if /camsnap\s+(.*)/.test(message)
    getImage RegExp.$1, (img) ->
      console.log(img)
      #bot.say(to, "http://solutions.3m.com/innovation/assets/logo.png")
      if img
        bot.say(to, img)
      else
        bot.say(to, "soRry bro!  bing must be down")


  # talk back
  else if /bingbot/.test(message)
    msg = message.replace(/bingbot/g, from)
    bot.say(to, msg)


sample = (array) ->
  return if !array || !array.length
  array[ Math.floor(array.length * Math.random()) ]


  



