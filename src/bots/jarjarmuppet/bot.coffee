BotBehavior = require('../../bot-behavior')

module.exports =
class Jarjarmuppet extends BotBehavior
	@use 'random'

	maxTimeBetweenGiberishInMinutes: 120

	@match(//, (match) ->
		@sayGiberishLater() unless @isWaitingToSpeak
	)

	sayGiberishLater: ->
		delay = @random(@maxTimeBetweenGiberishInMinutes * 60 * 1000)
		setTimeout(@sayGiberish, delay)
		@isWaitingToSpeak = true

	sayGiberish: =>
		messageText = @random(@api.giberish)
		@say(messageText)
		@isWaitingToSpeak = false
		@sayGiberishLater()


if require.main == module
	bot = require('../../injector').buildBotBehavior({name: 'jarjarmuppet'})
	bot.say = console.log
	bot.processMessage("hey there")


