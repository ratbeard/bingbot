module.exports = (bot, $api) ->

	bot.command "flip", ->
		bot.say($api.flipCoin())

	bot.command /roll(?: (\d+))?/, (match) ->
		numberOfSides = +match[1] || 6
		result = $api.rollDie(numberOfSides)
		bot.say("Rolled a #{result} on a #{numberOfSides}-sided die")
	
	bot.command /pick (.+)$/, (match) ->
		choices = match[1].split(/, ?| or /)
		result = $api.pick(choices)
		bot.say(result)

	#
	# Blackjack
	#
	blackjackGame = null
	bot.command("deal", ->
		if blackjackGame
			return bot.say("I'm already playing a game!")

		blackjackGame = new $api.BlackjackGame()
		blackjackGame.deal()
		bot.say blackjackGame.summary()
	)

	bot.command("hit me", ->
		if !blackjackGame
			return bot.say("Say 'deal' to start a new game")
		blackjackGame.dealCardToPlayer()
	)



	return bot

if require.main == module
	behavior = require('../../injector').injector.bot("wagerbot")
	behavior.onMessage("wagerbot: roll 0")
	behavior.onMessage("wagerbot roll 1")
	behavior.onMessage("roll 100000000")
	behavior.onMessage("wagerbot:flip")
	behavior.onMessage("wagerbot flip")
	behavior.onMessage("wagerbot: pick apple, rat face, cool")
	behavior.onMessage("wagerbot pick apple or m$ft")
	console.log behavior.pendingMessages
	behavior.pendingMessages = []

	behavior.onMessage("wagerbot deal")
	console.log behavior.pendingMessages


