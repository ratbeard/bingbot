fs = require('fs')
path = require('path')
repl = require('repl')

# Ours
Connection = require('./irc-connection')
Bot = require('./bot')
		
class Session
	constructor: ->
		@bots = {}
		@repl = null
		@config = @readConfig()
		@masterbot = new Connection("masterbot")

	start: ->
		console.log "ヽ༼ຈل͜ຈ༽ﾉ Bingbot!"
		@startRepl()
		@expose('sesh', @)
		@loadBots()
		@connectMasterbot()
		@startLaunchBots()

	startLaunchBots: ->
		for name in @config.launchBots ? []
			console.log "launching #{name}..."
			@bots[name].connect()

	connectMasterbot: ->
		@masterbot.connect(@config)
		@masterbot.onMessage = (user, room, messageText) =>
			for name, bot of @bots
				continue if !bot.isConnected || bot.isDisabled
				bot.processMessage(messageText)

	readConfig: ->
		{
			server: "irc.freenode.net"
			channel: "coolkidsusa"
			launchBots: ['dogshitbot']
		}

	availableBots: ->
		fs.readdirSync(path.join(__dirname, "bots"))

	loadBots: () ->
		ircConfig = @readConfig()
		for name in @availableBots()
			bot = new Bot(name, ircConfig)
			@bots[name] = bot
			@expose(name, bot)
			@expose('d', bot) if name == 'dogshitbot' # dev helper
		
	startRepl: ->
		@repl = repl.start({})

	expose: (name, value) ->
		@repl.context[name] = value
		

sesh = new Session()
sesh.start()

#masterListener.onMessage = (user, room, messageText) ->
	#for name, bot of bots
		#continue unless bot.isConnected
		#bot.processMessage(messageText)

	#if match = /summon ([^\s]+)/.exec(messageText)
		#botName = match[1]
		#bot = repl.context[botName]
		#console.log "summonning bot: #{botName}"
		#if !bot
			#console.error "no bot named"
		#else if !bot.connect
			#console.error "umm that aint a bot"
		#else if bot.isConnected
			#console.log "already connected fool"
		#else
			#bot.connect()

