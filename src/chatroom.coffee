irc = require('irc')

class Chatroom
	constructor: ({@server, @room, @user}) ->

	connect: ->
		@client = new irc.Client(@server, @user,
			debug: true
			channels: ["##{@room}"]
		)
		@client.addListener("error", @onError)
		@client.addListener("message", @onMessage)

	disconnect: ->
		throw "fuk"

	onMessage: (user, room, message) ->
		console.log "#{user}:'#{message}'"

	onError: (error) ->
		console.error "fuk:", error


exports = Chatroom
