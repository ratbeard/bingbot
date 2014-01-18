BotBehavior = require('../../bot-behavior')

module.exports =
class Secretary extends BotBehavior
	@match(/hey there/, (match) ->
		@say 'hey yourself, "dog"'
	)

if require.main == module
	bot = new Secretary
	bot.api = require('./api')
	bot.say = console.log
	bot.processMessage("hey there")


