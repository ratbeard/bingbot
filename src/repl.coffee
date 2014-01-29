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
		@startFileWatcher()
		@startRepl()
		@exposeReplProperties()
		@loadBots()
		@connectMasterbot()
		@startLaunchBots()
		@startPendingMessagePoller()

	# On changing any file within this tree, bot behaviors are reloaded
	# TODO - reload service changes as well
	# TODO - watch for new dirs that are added
	startFileWatcher: ->
		baseDirectory = __dirname

		addWatch = (directory) =>
			#console.log 'Watching directory for changes:', directory
			fs.watch(directory, @reloadBotBehavior)

		addWatchIfDirectory = (file) ->
			fs.stat file, (err, stat) ->
				return unless stat?.isDirectory()
				walkDirectory(file)
			
		walkDirectory = (directory) ->
			addWatch(directory)
			fs.readdir directory, (err, files) ->
				for file in files
					addWatchIfDirectory(path.join(directory, file))

		walkDirectory(baseDirectory)

	reloadBotBehavior: =>
		for name, bot of @bots
			try
				bot.reload()
			catch e
				console.error("ERROR reloading bot: #{name}")
				console.error(e)

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
				status = bot.isConnected() && "*" || " "
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
		@masterbot.onMessage = (user, room, body) =>
			# TODO move this somewhere else
			if match = /^(?:masterbot:? ?)summon ([^ ]+)/.exec(body)
				name = match[1]
				bot = @bots[name]
				console.log 'summoning', name
				if !bot
					@masterbot.say "ERR: Unknown bot `#{name}`"
				else if bot && bot.isConnected()
					@masterbot.say "ERR: `#{name}` is already connected"
				else
					bot.connect()
					@masterbot.say "Summoning `#{name}`"

			if match = /^(?:masterbot:? ?)kick ([^ ]+)/.exec(body)
				name = match[1]
				bot = @bots[name]
				console.log 'kicking', name
				if !bot
					@masterbot.say "ERR: Unknown bot `#{name}`"
				else if bot && !bot.isConnected()
					@masterbot.say "ERR: `#{name}` is not connected"
				else
					bot.disconnect()

			if match = /^(?:masterbot:? ?)bots/.exec(body)
				names = []
				for name, bot of @bots
					names.push(name)
				@masterbot.say(names.join(", "))

			if match = /^(?:masterbot:? ?)quit/.exec(body)
				throw "fuk"
			

			# TODO implement txt filters here
			for name, bot of @bots
				continue if !bot.isConnected() || bot.isDisabled
				bot.onMessage(body)

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

