module.exports = ($twilio, $contacts) ->
	error = (message, callback) ->
		console.error("ERROR", message)
		callback?(message)

	return {
		getPhoneNumber: (usernameOrPhoneNumber, callback) ->
			isPhoneNumber = /^\+\d{11}$/.test(usernameOrPhoneNumber)
			if isPhoneNumber
				callback(null, usernameOrPhoneNumber)
			else
				username = usernameOrPhoneNumber
				$contacts.get(username, (user) ->
					return error("Couldn't find user #{username}", callback) unless user
					return error("No `phone` set for `#{username}`", callback) unless user.phone
					callback(null, user.phone)
				)

		sendTextMessage: (usernameOrPhoneNumber, body, callback) ->
			@getPhoneNumber(usernameOrPhoneNumber, (err, phoneNumber) ->
				return error(err, callback) if err
				$twilio.sendTextMessage(phoneNumber, body, (err, message) ->
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
	api.sendTextMessage(to, body)


