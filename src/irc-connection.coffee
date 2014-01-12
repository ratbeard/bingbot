irc = require('irc')

class Connection
	constructor: (@name) ->

	connect: (ircConfig) ->
		@server = ircConfig.server
		@channel = ircConfig.channel
		@channel = "#" + @channel unless @channel[0] == '#'
		throw "bad ircConfig: #{ircConfig}" unless @server? && @channel?
		@irc = new irc.Client(@server, @name,
			debug: true
			channels: [@channel]
		)
		@irc.addListener("error", (error) =>
			@onError(error)
		)
		@irc.addListener("message", (a,b,c) =>
			@onMessage(a,b,c)
		)

	disconnect: ->
		@irc.disconnect()

	onMessage: (user, room, said) ->
		#console.log "#{user}:'#{message}'"

	onError: (error) ->
		console.error "fuk:", error

	say: (messageText) ->
		@irc.say(@channel, messageText)


class Listener extends Connection
	constructor: (@name, @queue) ->
		super

	onMessage: (user, room, said) ->
		console.log "> #{user}: #{said}'"



class Responder
	constructor: (ircConfig) ->
		@chatroom = new IrcConnection(ircConfig)

	say: (messageText) ->
		@chatroom.say(messageText)

class MessageQueue
	constructor: ->

	addIncomingMessage: (message) ->
		for bot in connectedBots when !bot.isDisabled
			bot.processMessage(message)

	addOutgoingMessage: (bot, messageText) ->
		if bot.isDisabled
			return console.log "DENIED", messageText

		bot.connection.say(messageText)


		
module.exports = {Connection, Listener, Responder, MessageQueue}

