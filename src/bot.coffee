#
# A bot is a high level delegate-like object.  It connects to the chatroom and
# puts on a pretty face, but doesn't implement the actual behavior.  In the
# repl, each bot gets its own instance variable which can command.
#
Connection = require('./irc-connection')
injector = require('./injector')

# Just clear the whole cache for now
clearRequireCache = ->
	for k, v of require.cache
		delete require.cache[k]

module.exports =
class Bot
	constructor: (@name, @ircConfig) ->
		@connection = null
		@behavior = null
		@isConnected = false

	connect: () ->
		@reload()
		@connection = new Connection(@name)
		@connection.connect(@ircConfig)
		@isConnected = true

	disconnect: ->
		@isConnected = true
		@connection.disconnect()

	reload: ->
		clearRequireCache()
		@load()

	load: ->
		behaviorFn = require("./bots/#{@name}/bot.coffee")
		@behavior = injector.inject(behaviorFn, {})

	onMessage: (messageText) ->
		@behavior.onMessage(messageText)

	say: (body) ->
		#console.log 'saying', body
		@connection.say(body)

	deliverPendingMessages: ->
		while body = @behavior?.pendingMessages.shift()
			@say body

