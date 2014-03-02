# Wrapper around twillio node library
#
# http://twilio.github.io/twilio-node/
module.exports = (secrets) ->
	twilio = require('twilio')
	[sid, token, from] = secrets.get("twilio.sid", "twilio.token", "twilio.phone")
	client = twilio(sid, token)

	return {
		sendText: (to, body, callback) ->
			client.sendSms({body, to, from}, callback)
	}
