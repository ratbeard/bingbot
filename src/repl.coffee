fs = require('fs')
path = require('path')
repl = require('repl').start({})
Chatroom = require('./chatroom')

#
# Utils
#
extend = (target, src) ->
	for k, v of src
		target[k] = v
		
#
# State
#
chatroom = null


#
# Bot loading
#

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
	fs.readdirSync(path.join(__dirname, "bots"))

#
# Master bot connection
#
connectToChatroom = ->
	ircConfig =
		server: "irc.freenode.net"
		channel: "coolkidsusa"
		user: "masterbot"
	console.log Chatroom
	#chatroom = new Chatroom(ircConfig)


#
# Init
#
connectToChatroom()
loadBots()
extend(repl.context, {reload})

