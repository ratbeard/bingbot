module.exports = (Q, twilio, contacts) ->
	return {
		# Converts a phone number string to the format twilio expects:
		#
		#     +12223334444
		#
		# returns null if it can't convert it.
		normalizePhoneNumber: (string) ->
			string = String(string).replace(/[^\d]/g, "")
			switch string.length
				when 10 # e.g. 9529133099
					"+1#{string}"
				when 11 # e.g. 19529133099
					"+#{string}"
				else
					null

		# Returns a promise resolving to a phone number
		getPhoneNumber: (usernameOrPhoneNumber, callback) ->
			if phoneNumber = @normalizePhoneNumber(usernameOrPhoneNumber)
				return Q.resolve(phoneNumber)

			username = usernameOrPhoneNumber
			contacts.get(username).then((user) ->
				user.phone ? throw Error("Contact `#{username}` didn't have a phone number")
			)

		sendText: (usernameOrPhoneNumber, body) ->
			@getPhoneNumber(usernameOrPhoneNumber)
				.then((phoneNumber) ->
					twilio.sendText(phoneNumber, body)
				)
	}

