module.exports = (command, say, api) ->

	command "hi", ->
		say "hello"

	command /txt ([^ ]+) (.+)/, (match) ->
		[usernameOrPhoneNumber, body] = match

		api.sendText(usernameOrPhoneNumber, body)
			.then(-> say 'Message delivered :)')
			.catch((error) -> say "Error: #{error}")

	
