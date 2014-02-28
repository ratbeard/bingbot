module.exports = (command, say) ->

	command "hi", ->
		say "it is all good."

	command /txt ([^ ]+) (.+)/, (match) ->
		usernameOrPhoneNumber = match[1]
		body = match[2]
		$api.sendSms(usernameOrPhoneNumber, body, (err, message) ->
			return bot.say "Error: #{err}" if err
			bot.say "Message delivered :)"
		)

	
