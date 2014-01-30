irc = require('irc')

class BotConnection
	constructor: (@server, @channel, @name, @delegate) ->
		@channel = "##{@channel}" unless @channel[0] == '#'
		# TODO
		@nameInChannel = null

	connect: () ->
		@irc = new irc.Client(@server, @name, {debug: true, channels: [@channel]})
		@irc.addListener("error", @onError)
		@irc.addListener("message",@onMessage)

	disconnect: ->
		@irc.disconnect()

	onMessage: (user, room, body) =>
		#console.log "#{user}:'#{body}'"
		message = {user, room, body}
		@delegate.onMessage(message)

	onError: (error) =>
		console.error "irc error: #{error}".red

	say: (body) ->
		@irc.say(@channel, body)

module.exports = BotConnection

