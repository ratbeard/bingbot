{injector} = require('./injector')
{error} = require('./utils')

# Just clear the whole cache for now
clearRequireCache = ->
	for k, v of require.cache
		delete require.cache[k]

class BotControl
	constructor: (@name, @connection) ->
		@behavior = null

	connect: () ->
		@reload()
		@connection.connect()

	disconnect: ->
		@connection.disconnect()

	isConnected: ->
		@connection && !@connection.irc.conn.destroyed

	reload: ->
		clearRequireCache()
		@load()

	load: ->
		behaviorFn = require("./bots/#{@name}/bot.coffee")
		@behavior = injector.inject(behaviorFn, {botName: => @name})

	onMessage: (message) ->
		try
			@behavior.onMessage(message)
		catch e
			error("`#{@name}` blew up on message:`#{messageText}`", e)

	say: (body) ->
		#console.log 'saying', body
		@connection.say(body)

	deliverPendingMessages: ->
		while body = @behavior?.pendingMessages.shift()
			@say body

module.exports = BotControl

