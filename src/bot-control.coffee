{injector} = require('./injector')

# Just clear the whole cache for now
clearRequireCache = ->
	for k, v of require.cache
		delete require.cache[k]

class BotControl
	constructor: (@name, @connection) ->
		@behavior = null

	connect: () ->
		#@reload()
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

	onMessage: (messageText) ->
		try
			@behavior.onMessage(messageText)
		catch e
			console.error("`#{@name}` blew up on:`#{messageText}`.  Error: \n#{e}".red)

	say: (body) ->
		#console.log 'saying', body
		@connection.say(body)

	deliverPendingMessages: ->
		while body = @behavior?.pendingMessages.shift()
			@say body

module.exports = BotControl

