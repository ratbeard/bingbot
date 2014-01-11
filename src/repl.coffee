fs = require('fs')
repl = require('repl').start({})

#
# Utils
#
extend = (target, src) ->
	for k, v of src
		target[k] = v
		
# Reload the bots
reload = ->
	console.log 'Reloading!'
	clearRequireCache()
	loadBots()

clearRequireCache = ->
	require.cache = {}

loadBots = ->
	for name in availableBotNames()
		loadBot(name)
	repl.context.bots = availableBotNames()

loadBot = (name) ->
	bot = require("./bots/#{name}/bot.coffee")
	repl.context[name] = bot
	# dev helper
	repl.context.d = bot if name == 'dogshitbot'

availableBotNames = ->
	fs.readdirSync "./bots"

# Init
loadBots()
extend(repl.context, {reload})
