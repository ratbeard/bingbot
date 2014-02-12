colors = require('colors')
fs = require('fs')
path = require('path')
_ = require('underscore')
inject = require('./inject')
Matcher = require('./Matcher')

class Bot
	constructor: (@botName, @connection, @behavior) ->

	connect: ->
		@connection.connect()

irc = require('irc')
class Connection
	constructor: (config, botName) ->
		{server, channel} = config.read()
		console.log "config!!", server, channel
		throw "bad ircConfig: #{config}" unless server? && channel?
		channel = "#" + channel unless channel[0] == '#'
		@server = server
		@channel = channel
		@name = botName
		@irc = new irc.Client(@server, @name, debug: true, channels: [@channel])
		@on 'error', (e) ->
			console.error("fuk:".red, e)

	connect: ->
		@irc.connect()

	on: (eventName, handler) ->
		@irc.on(eventName, handler)

	say: (body) ->
		@irc.say(@channel, body)

command = (Matcher, behavior) ->
	return (matchingExpression, handler) ->
		behavior.matchers.push(new Matcher(matchingExpression, handler))


MessageQueue = (session) ->
	return {
		addOutgoing: (message) ->
			{body, from} = message
			console.log "[#{from}]: #{body}"
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

	onMessage: (message) ->
		for matcher in @matchers
			if matcher.doesMatch(message.body)
				console.log 'it matched', matcher
				matcher.handler()

env = () ->
	homeDir: process.env.HOME
	name: 'dev' #argv.env

config = (env) ->
	return {
		read: ->
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
	}

class Session
	constructor: (config) ->
		@config = config.read()
		@bots = {}
		@botDir = path.join(__dirname, "bots")
		@botNames = fs.readdirSync(@botDir)
		@loadBots()

	start: ->
		@bots.masterbot.connect()

	readBots: ->
		for name in @botNames
			behaviorBuilder = require("#{@botDir}/#{name}/behavior")
			apiBuilder = require("#{@botDir}/#{name}/api")
			{botName: name, apiBuilder, behaviorBuilder}

	loadBots: ->
		locals = {session: @}
		messages = inject(MessageQueue, locals)
		for x in @readBots()
			{botName, apiBuilder, behaviorBuilder} = x
			locals.botName = botName
			locals.messages = messages
			locals.connection = inject.core(Connection, locals)
			locals.behavior = new Behavior
			inject.core(behaviorBuilder, locals)
			@bots[botName] = inject(Bot, locals)

inject.core = (builder, locals) ->
	inject(builder, _.extend({}, coreServices, locals))

module.exports = coreServices = {
	config,
	env,
	say,
	command,
	Bot,
	Connection,
	MessageQueue,
	Behavior,
	Session,
	Matcher,
	inject
}

if require.main == module
	console.log 'dece'
	session = inject.core(Session)
	session.start()
