BotBehavior = require('../../bot-behavior')

module.exports =
class <%= botClass %> extends BotBehavior
	@match(/hey there/, (match) ->
		@say 'hey yourself, "dog"'
	)

if require.main == module
	bot = new <%= botClass %>
	bot.api = require('./api')
	bot.say = console.log
	bot.processMessage("hey there")


