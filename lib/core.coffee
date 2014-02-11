fs = require('fs')
path = require('path')
_ = require('underscore')
inject = require('./inject')
Matcher = require('./Matcher')

class Bot
	constructor: (@name, @connection, @behavior) ->

	connect: ->
		@connection.connect()

irc = require('irc')
class Connection
	constructor: (config) ->
		{server, channel} = config.read()
		throw "bad ircConfig: #{config}" unless server? && channel?
		channel = "#" + channel unless channel[0] == '#'
		@server = server
		@channel = channel
		@irc = new irc.Client(@server, @name, debug: true, channels: [@channel])

	connect: ->
		@irc.connect()

command = (Matcher, behavior) ->
	return (matchingExpression, handler) ->
		behavior.matchers.push(new Matcher(matchingExpression, handler))

ActiveBots = ->
	return @instance if @instance
	@bots = []
	@instance = @


MessageQueue = inject((ActiveBots) ->
	return {outgoing: []}
, {ActiveBots})
MessageQueue.singleton = true


say = inject((MessageQueue) ->
	return (body) ->
		#console.log 'saying!!!!!', body
		MessageQueue.outgoing.push(body)
, {MessageQueue})
say.inject = false


class Behavior
	@inject = (builder, locals) ->
		behavior = new Behavior
		locals = _.extend({}, {behavior}, locals)
		inject.core(builder, locals)
		behavior

	constructor: (builder, locals) ->
		@matchers = []

	onMessage: (message) ->
		for matcher in @matchers
			if matcher.doesMatch(message.body)
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
		@bots.masterbot.connect()

	readBots: ->
		for name in @botNames
			behaviorBuilder = require("#{@botDir}/#{name}/behavior")
			apiBuilder = require("#{@botDir}/#{name}/api")
			{name, apiBuilder, behaviorBuilder}


	loadBots: ->
		for x in @readBots()
			{name, apiBuilder, behaviorBuilder} = x
			connection = inject.core(Connection)
			behavior = Behavior.inject(behaviorBuilder)
			@bots[name] = new Bot(name, connection, behavior)

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
	ActiveBots,
	Behavior,
	Session,
	Matcher,
	inject
}

if require.main == module
	console.log 'dece'
