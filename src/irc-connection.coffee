irc = require('irc')

module.exports =
class Connection
	constructor: (@name) ->

	connect: (ircConfig) ->
		{server, channel} = ircConfig
		throw "bad ircConfig: #{ircConfig}" unless server? && channel?
		channel = "#" + channel unless channel[0] == '#'
		@server = server
		@channel = channel
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

