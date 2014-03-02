module.exports = (twilio, contacts) ->
	error = (message, callback) ->
		console.error("ERROR: #{message}".red)
		callback?(message)

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

		getPhoneNumber: (usernameOrPhoneNumber, callback) ->
			phoneNumber = @normalizePhoneNumber(usernameOrPhoneNumber)
			if phoneNumber
				callback(null, phoneNumber)
				return

			username = usernameOrPhoneNumber
			contacts.get(username, (user) ->
				return error("Couldn't find user #{username}", callback) unless user
				return error("No `phone` set for `#{username}`", callback) unless user.phone
				callback(null, user.phone)
			)

		sendText: (usernameOrPhoneNumber, body, callback) ->
			@getPhoneNumber(usernameOrPhoneNumber, (err, phoneNumber) ->
				return error(err, callback) if err
				twilio.sendSms(phoneNumber, body, (err, message) ->
					callback?()
				)
			)
	}

# ====
if require.main == module
	injector = require('../../injector')
	api = injector.inject(module.exports, services)
	body = "sup dog?"
	to = "encryptd_fractal"
	api.sendSms(to, body)


