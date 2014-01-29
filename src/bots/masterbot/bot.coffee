module.exports = (bot) ->
	bot.command /summon ([^ ]+)/, (match) ->
		name = match[1]
		b = @bots[name]
		console.log 'summoning', name
		if !b
			bot.say "ERR: Unknown bot `#{name}`"
		else if b && b.isConnected()
			bot.say "ERR: `#{name}` is already connected"
		else
			b.connect()
			bot.say "Summoning `#{name}`"

	
	bot.command /kick ([^ ]+)/, (match) ->
		name = match[1]
		b = @bots[name]
		console.log 'kicking', name
		if !b
			bot.say "ERR: Unknown bot `#{name}`"
		else if b && !b.isConnected()
			bot.say "ERR: `#{name}` is not connected"
		else
			b.disconnect()

	bot.command /bots/, (match) ->
		names = []
		for name, b of @bots
			names.push(name)
		bot.say(names.join(", "))

	bot.command /quit/, (match) ->
		throw "fuk"

	bot.match /.*/, (match) ->
		body = match[0]
		console.log 'heard', body
		for name, b of @bots
			continue if !b.isConnected() || b.isDisabled
			b.onMessage(body)



