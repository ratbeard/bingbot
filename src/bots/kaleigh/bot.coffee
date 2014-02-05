module.exports = ($api, bot, $room) ->

	bot.command(/txt ([^ ]+) (.+)/, (match) ->
		usernameOrPhoneNumber = match[1]
		body = match[2]
		$api.sendSms(usernameOrPhoneNumber, body, (err, message) ->
			return bot.say "Error: #{err}" if err
			bot.say "Message delivered :)"
		)
	)

	messagesToDeliver = []
	bot.command(/tell ([^ ]+) (.+)/, (match) ->
		username = match[1]
		body = match[2]
		from = null

		if $room.user(username)
			console.log 'in room'
			bot.say "Tell him yourself, #{from}"
		else
			console.log 'not in room'
			to = username
			messagesToDeliver.push({to, from, body})
	)
	
	$room.onUserJoin((username) ->
		console.log 'Well well well, look who decided to show up', username
		for message in messagesToDeliver
			if message.to == username
				{to, from, body} = message
				@say "#{to}, you have a message from #{from}:"
				@say body
	)

	return bot


if require.main == module
	behavior = require('../../injector').inject.bot('kaleigh')
	behavior.onMessage("txt encryptd_fractal cool")

