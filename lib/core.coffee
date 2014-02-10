_ = require('underscore')
inject = require('./inject')
command = require('./command')
Matcher = require('./Matcher')

class Bot
	constructor: (@name, @connection, @behavior) ->

	connect: ->
		@connection.connect()

irc = require('irc')
class Connection
	constructor: (ircConfig) ->
		{server, channel} = ircConfig
		throw "bad ircConfig: #{ircConfig}" unless server? && channel?
		channel = "#" + channel unless channel[0] == '#'
		@server = server
		@channel = channel
		@irc = new irc.Client(@server, @name, debug: true, channels: [@channel])

	connect: ->
		@irc.connect()

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


behaviorServices = {command, say, Matcher}
class Behavior
	constructor: (builder, locals) ->
		@matchers = []
		locals = _.extend({}, behaviorServices, {behavior: @}, locals)
		return inject(builder, locals)

	onMessage: (message) ->
		for matcher in @matchers
			if matcher.doesMatch(message.body)
				matcher.handler()

module.exports = {Bot, Connection, MessageQueue, ActiveBots, Behavior}

