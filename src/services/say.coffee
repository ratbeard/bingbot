module.exports = (bot) ->
	return (messageText) ->
		bot.connection.say(messageText)

