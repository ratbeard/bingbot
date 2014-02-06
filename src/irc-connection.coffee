irc = require('irc')

module.exports =
class Connection
	constructor: (@name, @ircConfig) ->

	connect: () ->
		{server, channel} = @ircConfig
		throw "bad ircConfig: #{ircConfig}" unless server? && channel?
		channel = "#" + channel unless channel[0] == '#'
		@server = server
		@channel = channel
		@irc = new irc.Client(@server, @name,
			debug: true
			channels: [@channel]
		)
		@irc.connect()
		@on("error", @onError)
		@on("message", @onMessage)

	on: (eventName, callback) ->
		@irc.addListener(eventName, callback)
	
	send: (messageBody) ->
		@irc.send(messageBody)

	disconnect: ->
		@irc.disconnect()

	onMessage: (user, room, said) =>
		#console.log "#{user}:'#{message}'"

	onError: (error) =>
		console.error "fuk:", error

	say: (messageText) ->
		@irc.say(@channel, messageText)

