fs = require('fs')
path = require('path')
_ = require('underscore')
irc = require('irc')
colors = require('colors')
inject = require('./inject')
Matcher = require('./Matcher')

class Bot
	constructor: (@botName, @connection, @behavior) ->

	connect: ->
		@connection.connect()

class Connection
	constructor: (config, botName, IrcClientFactory) ->
		{server, channel} = config
		throw "bad ircConfig: #{JSON.stringify(config)}" unless server? && channel?
		channel = "#" + channel unless channel[0] == '#'
		@server = server
		@channel = channel
		@botName = botName
		@client = IrcClientFactory.build(@server, @channel, @botName)
		@on 'error', (e) ->
			console.error("fuk:".red, e)

	connect: ->
		console.log("#{@botName} is connecting")
		@client.connect()

	on: (eventName, handler) ->
		@client.on(eventName, handler)

	say: (body) ->
		console.log "Connection.say()", body
		if @client
			@client.say(body)
		else
			console.log("[#{@botName} (disconnected)] #{body}")

IrcClientFactory = ->
	class IrcClient
		constructor: (@server, @channel, @botName) ->
			console.log 'making a client:', @server, @channel, @botName
			@irc = new irc.Client(@server, @botName, channels: [@channel], debug: true, autoConnect: false)

		on: (eventName, callback) ->
			@irc.on(eventName, callback)

		connect: ->
			console.log "IrcClient.connect() #{@botName}"
			@irc.connect()

		say: (body) ->
			console.log 'sayin', @channel, body
			@irc.say(@channel, body)

	return {
		build: (args...) ->
			console.log 'real building!'
			new IrcClient(args...)
	}

		
command = (Matcher, behavior) ->
	return (matchingExpression, handler) ->
		behavior.matchers.push(new Matcher(matchingExpression, handler))


MessageQueue = (session) ->
	return {
		addOutgoing: (message) ->
			{body, from} = message
			console.log "MessageQueue.addOutgoing(): #{from}, #{body}"
			bot = session.bots[from]
			isConnected = true
			if isConnected
				bot.connection.say(body)
			else
				console.log '... but not conected'

		addIncoming: (message) ->
			console.log 'messages.incoming add:', message.body
			for name, bot of session.bots
				console.log 'addincoming -', name
				bot.behavior.onMessage(message)
	}


say = (messages, botName) ->
	return (body) ->
		messages.addOutgoing({body, from: botName})


class Behavior
	constructor: () ->
		@matchers = []

	onMessage: (message, onMatch=@onMatch) ->
		for matcher in @matchers
			console.log 'm?', message
			if match = matcher.match(message)
				onMatch(matcher, match)

	onMatch: (matcher, match) ->
		matcher.handler(match)

	doesMatch: (message) ->
		result = false
		@onMessage(message, -> result = true)
		result

	

env = () ->
	homeDir: process.env.HOME
	name: 'dev' #argv.env
	name: 'local'

# Service which reads in config from the users home dir
# TODO create file if no exists
config = (env) ->
	configDir = path.join(env.homeDir, ".bingbot")
	configFile = path.join(configDir, "config.json")
	jsonString = fs.readFileSync(configFile)
	json = JSON.parse(jsonString)
	environmentConfig = json[env.name]
	if env.name && !environmentConfig
		console.error("""Hey I didn't see any config for '#{env.name}' in #{configFile}.
										 Only saw: #{Object.keys(json).join(' ')}""")
		throw "TRY BETTER NEXT TIME"
	_.extend(json.default, environmentConfig)


class Session
	constructor: (config, IrcClientFactory) ->
		@locals = {session: @, IrcClientFactory}
		@config = config
		@bots = {}
		@botDir = path.join(__dirname, "bots")
		@botNames = fs.readdirSync(@botDir)
		@loadBots()

	start: ->
		@connectMasterbot()
		@connectLaunchbots()
	
	connectMasterbot: ->
		@bots.masterbot.connect()

	connectLaunchbots: ->
		for name in @config.launchBots ? []
			@bots[name].connect()

	readBots: ->
		for name in @botNames
			behaviorBuilder = require("#{@botDir}/#{name}/behavior")
			apiBuilder = require("#{@botDir}/#{name}/api")
			{botName: name, apiBuilder, behaviorBuilder}

	loadBots: ->
		locals = _.extend({}, @locals)
		@messages = inject(MessageQueue, locals)
		for x in @readBots()
			{botName, apiBuilder, behaviorBuilder} = x
			locals.botName = botName
			# Build up connections, etc
			locals.messages = @messages
			locals.connection = inject.core(Connection, locals)
			# Build api and behavior
			locals.api = inject.core(apiBuilder, locals)
			locals.behavior = new Behavior
			inject.core(behaviorBuilder, locals)
			@bots[botName] = inject(Bot, locals)


inject.core = (builder, locals) ->
	inject(builder, _.extend({}, coreServices, locals))

module.exports = coreServices = {
	IrcClientFactory
	config
	env
	say
	command
	Bot
	Connection
	MessageQueue
	Behavior
	Session
	Matcher
	inject
}

servicesDir = "#{__dirname}/services"
services = fs.readdirSync(servicesDir)
services = services.map((f) -> f.split('.')[0])
for service in services
	console.log service
	coreServices[service] = require("#{servicesDir}/#{service}")

if require.main == module
	console.log 'dece'
	#ircClient = new irc.Client("irc.freenode.net", "hat", debug: true, autoConnect: false) 
	#ircClient = new irc.Client("localhost.net", "junkyard", debug: true, autoConnect: false)
	session = inject.core(Session)
	session.start()
