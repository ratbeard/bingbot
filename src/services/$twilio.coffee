module.exports = ($secrets) ->
	twilio = require('twilio')
	[sid, token, from] = $secrets.get("twilio.sid", "twilio.token", "twilio.phone")
	client = twilio(sid, token)

	return {
		sendTextMessage: (to, body, callback) ->
			client.sms.messages.create({body, to, from}, callback)
	}

