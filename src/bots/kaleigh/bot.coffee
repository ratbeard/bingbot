module.exports = ($api, bot) ->
	bot.match(/^txt ([^ ]+) (.+)$/, (match) ->
		[__, usernameOrPhoneNumber, body] = match
		console.log usernameOrPhoneNumber, body
		$api.sendSms(usernameOrPhoneNumber, body, (err, message) =>
			return @say "Error: #{err}" if err
			@say "Message delivered :)"
		)
	)
	return bot


if require.main == module
	behavior = require('../../injector').inject.bot('kaleigh')
	behavior.onMessage("txt encryptd_fractal cool")

