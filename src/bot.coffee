#
# A bot is a high level delegate-like object.  It connects to the chatroom and
# puts on a pretty face, but doesn't implement the actual behavior.  In the
# repl, each bot gets its own instance variable which can command.
#
Connection = require('./irc-connection')
{injector} = require('./injector')

# Just clear the whole cache for now
clearRequireCache = ->
	for k, v of require.cache
		delete require.cache[k]

module.exports =
class Bot
	constructor: (@name, @ircConfig) ->
		@connection = null
		@behavior = null

	connect: () ->
		@reload()
		@connection = new Connection(@name)
		@connection.connect(@ircConfig)

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

