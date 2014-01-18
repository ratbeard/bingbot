twilio = require 'twilio'

module.exports = () ->


if require.main == module
	console.log 'hi'
	sid = ""
	token = ""
	twilioClient = twilio(sid, token)

	body = "sup dog"
	to = "+"
	from = "+"
	twilioClient.sms.messages.create({body, to, from}, (err, message) ->
		console.log err
		console.log message
	)


