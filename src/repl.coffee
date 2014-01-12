fs = require('fs')
path = require('path')
repl = require('repl').start({})
chat = require('./irc-connection')


class Bot
	constructor: (@name, @ircConfig) ->
		@connection = null
		@behavior = null
		@isConnected = false

	connect: () ->
		@reload()
		@connection = new chat.Connection(@name)
		@connection.connect(@ircConfig)
		@isConnected = true

	disconnect: ->
		@isConnected = true
		@connection.disconnect()

	reload: ->
		clearRequireCache()
		@loadBehavior()

	loadBehavior: ->
		klass = require("./bots/#{@name}/bot.coffee")
		@behavior = new klass()
		# inject
		@behavior.say = (messageText) =>
			@connection.say(messageText)

	say: (messageText) ->
		@behavior.say(messageText)

	processMessage: (messageText) ->
		@behavior.processMessage(messageText)
#
# Utils
#
extend = (target, src) ->
	for k, v of src
		target[k] = v
		
#
# State
#
botNames = null
ircConfig = null
bots = {}

#
# Bot loading
#

# Reload the bots
reload = ->
	console.log 'Reloading!'
	clearRequireCache()
	loadBots()

clearRequireCache = ->
	for k, v of require.cache
		require.cache[k]
	for k, v of repl.context.require.cache
		delete repl.context.require.cache[k]

loadBots = ->
	botNames = fs.readdirSync(path.join(__dirname, "bots"))
	for name in botNames
		ircConfig =
			server: "irc.freenode.net"
			channel: "coolkidsusa"
		bot = new Bot(name, ircConfig)
		bots[name] = bot
		repl.context[name] = bot
		repl.context.d = bot if name == 'dogshitbot' # dev helper

	repl.context.botNames = botNames


#
# Master bot connection
#


#
# Init
#

#connectToChatroom()
loadBots()
extend(repl.context, {reload})

ircConfig =
	server: "irc.freenode.net"
	channel: "coolkidsusa"


queue = new chat.MessageQueue
masterListener = new chat.Listener("masterbot")
masterListener.connect(ircConfig)
masterListener.onMessage = (user, room, messageText) ->

	for name, bot of bots
		continue unless bot.isConnected
		bot.processMessage(messageText)

	if match = /summon ([^\s]+)/.exec(messageText)
		botName = match[1]
		bot = repl.context[botName]
		console.log "summonning bot: #{botName}"
		if !bot
			console.error "no bot named"
		else if !bot.connect
			console.error "umm that aint a bot"
		else if bot.isConnected
			console.log "already connected fool"
		else
			bot.connect()


repl.context.m = masterListener
repl.context.clear = clearRequireCache



