module.exports = (bot, random) ->
	maxTimeBetweenGiberishInMinutes = 120

	bot.match(/hey/, (match) ->
		bot.say "hey yerself"
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
	#registry = new Registry()
	#testBotService = ->
		#{
			#say: console.log
			#match: ->
		#}

	#registry.add('bot', testBotService)
	behavior = injector.inject(uninjectedBehavior)
	behavior.onMessage('hey')


