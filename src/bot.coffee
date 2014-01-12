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
		injector.buildBotBehavior(@)

	processMessage: (messageText) ->
		@behavior.processMessage(messageText)

	say: (messageText) ->
		@behavior.say(messageText)

