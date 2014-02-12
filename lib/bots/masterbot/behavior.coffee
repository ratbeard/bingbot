module.exports = (messages, connection) ->

	connection.on 'message', (user, room, said) ->
		console.log "#{user}: #{said}"
		messages.addIncoming({from: user, body: said})
