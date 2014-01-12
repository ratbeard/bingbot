BotBehavior = require('../../bot-behavior')

module.exports =
class Dogshitbot extends BotBehavior

	@match(/zup/, (message) ->
		@say ":-]"
	)
	@match(/cool/, (message) ->
		@say "HELL YEA!!!!!!"
	)

