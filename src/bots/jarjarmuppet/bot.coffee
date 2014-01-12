BotBehavior = require('../../bot-behavior')

module.exports =
class Jarjarmuppet extends BotBehavior
	@use 'random'

	maxTimeBetweenGiberishInMinutes: 1

	phrases: [
		"hey yo, daddy.	meesa back!"
		"hello boyo!"
		"watch out for da mackaneeks!"
		"mesa in deep doodoo!"
		"I don't know. mesa day startin pretty okee-day with a brisky morning munchy, then boom! gettin very scared and grabbin that jedi and pow!"
		"ooh mooey mooey i love you!"
	]

	@match(//, (match) ->
		@sayGiberishLater() unless @isWaitingToSpeak
	)

	sayGiberishLater: ->
		console.log("queueing some giberish!")
		delay = @random(@maxTimeBetweenGiberishInMinutes * 60 * 1000)
		setTimeout(@sayGiberish, delay)
		@isWaitingToSpeak = true

	sayGiberish: =>
		messageText = @random(@phrases)
		@say(messageText)
		@isWaitingToSpeak = false
		@sayGiberishLater()


if require.main == module
	bot = require('../../injector').buildBotBehavior({name: 'jarjarmuppet'})
	bot.say = console.log
	bot.processMessage("hey there")


