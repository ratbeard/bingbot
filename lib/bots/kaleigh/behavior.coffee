module.exports = (command, say, api) ->

	command "hi", ->
		say "hello"

	command /txt ([^ ]+) (.+)/, (match) ->
		usernameOrPhoneNumber = match[1]
		body = match[2]
		sayDelivered = (textMessage)->
			say "Message delivered :)"

		api.sendText(usernameOrPhoneNumber, body)
			.then(sayDelivered)
			.catch((error) -> say "Error: #{error}")

	
