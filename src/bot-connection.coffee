irc = require('irc')

class BotConnection
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
		@irc.addListener("error", @onError)
		@irc.addListener("message",@onMessage)

	disconnect: ->
		@irc.disconnect()

	onMessage: (user, room, said) ->
		#console.log "#{user}:'#{message}'"

	onError: (error) ->
		console.error "irc error: #{error}".red

	say: (messageText) ->
		@irc.say(@channel, messageText)

module.exports = BotConnection

