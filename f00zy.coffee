irc = require('irc')
fs = require('fs')

bot = new irc.Client('irc.freenode.net', 'f00zy',
  debug: true,
  channels: ['#mikesrealm']
)

bot.addListener 'error', (message) ->
  console.error 'fuk:', message


bot.addListener 'message', (from, to, message) ->
  console.log('%s => %s: %s', from, to, message)

  if match = message.match(/(\w+) and (\w+) beat (\w+) and (\w+) (\d) to (\d)/)
    [_, winner1, winner2, loser1, loser2, wins, losses] = match
    addGameResult({winner1, winner2, loser1, loser2, wins, losses})

  else if match = message.match(/stats/)
    for game in games

# Store/retrieve results from file
games = []

addGameResult = (gameData) ->
  games.push(gameData)
  #console.log(games)
  saveToFile()

saveToFile = () ->
  console.log("Saving results to file:", games)
  json = JSON.stringify(games, undefined, "  ")
  fs.writeFile "./games.json", json

readFromFile = () ->
  fs.readFile "./games.json", (err, data) ->
    if err
      console.log("couldnt read from file", err)
      return

    if !data || !data.length
      console.log 'no data'
      return

    games = JSON.parse(data)
    console.log("read game data:", games)
  

readFromFile()
#addGameResult({a: 1, b: 2})
#saveToFile()
