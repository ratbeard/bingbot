module.exports = (command, say, api) ->

	command "hi", ->
		say "hello"

	command /txt ([^ ]+) (.+)/, (match) ->
		usernameOrPhoneNumber = match[1]
		body = match[2]
		api.sendText(usernameOrPhoneNumber, body, (err, message) ->
			return say("Error: #{err}") if err
			say "Message delivered :)"
		)

	
