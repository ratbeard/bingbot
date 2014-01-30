fs = require('fs')
path = require('path')
repl = require('repl')
colors = require('colors')
optimist = require('optimist')

BotConnection = require('./bot-connection')
BotControl = require('./bot-control')
{extend, error} = require('./utils')

# Parse command line options
argv = optimist
	.usage('-e dev')
	.alias('e', 'env')
	.describe('e', 'Set an environment, whose settings in ~/.bingbot/config.json will be merged into the defaults')
	.default('env', "default")
	.argv

class Session
	constructor: ->
		@bots = {}
		@repl = null
		@masterBot = null
		@config = @readConfig()

	start: ->
		console.log "ヽ༼ຈل͜ຈ༽ﾉ Bingbot!".rainbow
		@startFileWatcher()
		@startRepl()
		@loadBots()
		@launchMasterbot()
		@launchStartingBots()
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
				error("`#{name}` blew up while reloading", e)

	startPendingMessagePoller: ->
		x = =>
			#console.log 'checking...'
			for name, bot of @bots
				bot.deliverPendingMessages()
			setTimeout(x, 500)
		x()

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
			console.error """
				Hey I didn't see any config for `#{environmentName}` in `#{configFilePath}`

				Only saw: #{Object.keys(json).join(' ')}
				
					TRY BETTER NEXT TIME""".red
			process.exit(1)

		extend(json.default, environmentConfig)

	availableBots: ->
		fs.readdirSync(path.join(__dirname, "bots"))

	launchStartingBots: ->
		return
		for name in @config.launchBots ? []
			console.log "launching #{name}..."
			@bots[name].connect()

	launchMasterbot: ->
		console.log "launching masterbot..."
		name = "masterbot"
		delegate = {
			onMessage: (message) ->
				botControl.onMessage(message)
		}
		connection = new BotConnection(@config.server, @config.channel, name, delegate)
		botControl = new BotControl(name, connection)
		botControl.connect()
		@masterbot = botControl

	loadBots: () ->
		for name in @availableBots()
			continue if @bots[name]
			connection = new BotConnection(@config.server, @config.channel, name)
			botControl = new BotControl(name, connection)
			@bots[name] = botControl
			@expose(name, botControl)
		
	startRepl: ->
		@repl = repl.start({})
		@expose('sesh', @)
		@exposeGetter "bots", =>
			@loadBots()
			console.log("\nBots:")
			for name, bot of @bots
				status = bot.isConnected() && "*" || " "
				console.log(" (%s)	%s", status, name)
			console.log("")

	expose: (name, value) ->
		@repl.context[name] = value

	exposeGetter: (name, value) ->
		Object.defineProperty(@repl.context, name, get: value)

		

sesh = new Session()
sesh.start()

