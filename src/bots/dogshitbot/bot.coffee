BotBehavior = require('../../bot-behavior')

module.exports =
class Dogshitbot extends BotBehavior
	@use 'random'

	@match(/zup/, (message) ->
		messageText = @random(["hi", ":[", "ok"])
		@say(messageText)
	)
	@match(/cool/, (message) ->
		@say "HELL YEA!!!!!!"
	)

