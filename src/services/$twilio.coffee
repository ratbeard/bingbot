module.exports = ($secrets) ->
	twilio = require('twilio')
	[sid, token, from] = $secrets.get("twilio.sid", "twilio.token", "twilio.phone")
	client = twilio(sid, token)

	return {
		sendSms: (to, body, callback) ->
			client.sendSms({body, to, from}, callback)

		# http://twilio.github.io/twilio-node/
		#makeCall:
	}

