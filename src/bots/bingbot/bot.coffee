BotBehavior = require('../../bot-behavior')

module.exports =
class Bingbot extends BotBehavior
	@match(/bing (.+)/, ([_, phrase]) ->
		@api.topResult(phrase, (result) =>
			messageText = "( ͡° ͜ʖ ͡°) " + result
			@say messageText
		)
	)

if require.main == module
	bot = new Bingbot
	bot.api = require('./api')
	bot.say = console.log
	bot.processMessage("bing cats on parade")

