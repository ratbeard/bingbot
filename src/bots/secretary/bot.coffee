module.exports = ($api, bot) ->
	bot.match(/^txt ([^ ]+) (.+)$/, (match) ->
		[__, usernameOrPhoneNumber, body] = match
		console.log usernameOrPhoneNumber, body
		$api.sendTextMessage(usernameOrPhoneNumber, body, (err, message) =>
			return @say "Error: #{err}" if err
			@say "Message delivered :)"
		)
	)
	return bot


if require.main == module
	{injector, services} = require('../../injector')
	behavior = injector.inject(module.exports, services)
	behavior.onMessage("txt encryptd_fractal cool")

