fs = require('fs')
path = require('path')
repl = require('repl')
_ = require('underscore')
argv = require('optimist')
	.usage('-e dev')
	.alias('e', 'env')
	.describe('e', 'Set an environment, whose settings in ~/.bingbot/config.json will be merged into the defaults')
	.default('env', "default")
	.argv

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
		@exposeReplProperties()
		@loadBots()
		@connectMasterbot()
		@startLaunchBots()
		@startPendingMessagePoller()

	startPendingMessagePoller: ->
		x = =>
			#console.log 'checking...'
			for name, bot of @bots
				bot.deliverPendingMessages()
			setTimeout(x, 500)
		x()

	exposeReplProperties: ->
		@expose('sesh', @)
		@exposeGetter("bots", =>
			@loadBots()
			console.log("\nBots:")
			for name, bot of @bots
				status = bot.isConnected && "*" || " "
				console.log(" (%s)	%s", status, name)
			console.log("")
		)

	startLaunchBots: ->
		for name in @config.launchBots ? []
			console.log "launching #{name}..."
			@bots[name].connect()

	connectMasterbot: ->
		console.log "launching masterbot..."
		@masterbot.connect(@config)
		@masterbot.onMessage = (user, room, messageText) =>
			for name, bot of @bots
				continue if !bot.isConnected || bot.isDisabled
				bot.onMessage(messageText)

	getEnvironmentName: ->
		argv.env

	readConfig: ->
		configDirPath = path.join(process.env.HOME, ".bingbot")
		configFilePath = path.join(configDirPath, "config.json")
		jsonText = fs.readFileSync(configFilePath)
		json = JSON.parse(jsonText)
		environmentName = @getEnvironmentName()
		environmentConfig = json[environmentName]
		if environmentName && !environmentConfig
			console.error("""Hey I didn't see any config for '#{environmentName}' in #{configFilePath}.
											 Only saw: #{Object.keys(json).join(' ')}""")
			throw "TRY BETTER NEXT TIME"
		_.extend(json.default, environmentConfig)

	availableBots: ->
		fs.readdirSync(path.join(__dirname, "bots"))

	loadBots: () ->
		ircConfig = @readConfig()
		for name in @availableBots()
			continue if @bots[name]
			bot = new Bot(name, ircConfig)
			@bots[name] = bot
			@expose(name, bot)
			@expose('d', bot) if name == 'dogshitbot' # dev helper
		
	startRepl: ->
		@repl = repl.start({})

	expose: (name, value) ->
		@repl.context[name] = value

	exposeGetter: (name, value) ->
		Object.defineProperty(@repl.context, name, get: value)

		

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

