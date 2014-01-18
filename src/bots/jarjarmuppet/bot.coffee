module.exports = (bot, random) ->
	maxTimeBetweenGiberishInMinutes = 120

	bot.match(/hey/, (match) ->
		bot.say "ey yerself"
	)
	bot.match(/rand/, (match) ->
		bot.say random(100)
	)

	bot.match(//, ->
		sayGiberishLater() unless @isWaitingToSpeak
	)

	sayGiberishLater = ->
		delay = random(maxTimeBetweenGiberishInMinutes * 60 * 1000)
		setTimeout(sayGiberish, delay)
		isWaitingToSpeak = true

	sayGiberish = =>
		messageText = random(api.giberish)
		say(messageText)
		isWaitingToSpeak = false
		sayGiberishLater()

	return bot

if require.main == module
	injector = require('../../injector')
	#bot = injector.botBehavior({name: 'jarjarmuppet'})
	uninjectedBehavior = module.exports
	testServices = {
		say: console.log
	}
	behavior = injector.inject(uninjectedBehavior, testServices)
	behavior.onMessage('hey')


