fs = require('fs')
path = require('path')
repl = require('repl').start({})
chat = require('./irc-connection')

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
	botNames = fs.readdirSync(path.join(__dirname, "bots"))
	for name in botNames
		#loadBot(name)
		ircConfig =
			server: "irc.freenode.net"
			channel: "coolkidsusa"
		bot = new chat.Bot(name, ircConfig)
		repl.context[name] = bot
		repl.context.d = bot if name == 'dogshitbot'
	repl.context.bots = botNames

loadBot = (name) ->
	bot = require("./bots/#{name}/bot.coffee")
	repl.context[name] = bot
	# dev helper
	repl.context.d = bot if name == 'dogshitbot'

#
# Master bot connection
#
connectToChatroom = ->
	console.log Chatroom
	#chatroom = new Chatroom(ircConfig)


#
# Init
#

#connectToChatroom()
loadBots()
extend(repl.context, {reload})

ircConfig =
	server: "irc.freenode.net"
	channel: "coolkidsusa"


messageQueue = new chat.MessageQueue
masterListener = new chat.Listener("masterbot")
masterListener.connect(ircConfig)
masterListener.onMessage = (user, room, said) ->
	console.log 'i heard dat'
	if match = /summon ([^\s]+)/.exec(said)
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
masterListener

repl.context.m = masterListener


