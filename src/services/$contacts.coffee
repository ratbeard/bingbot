module.exports = ($secrets) ->
	contacts = $secrets.get("contacts")
	return {
		get: (username, callback) ->
			for contact in contacts
				if contact.username == username
					return callback(contact)
			callback(null)
	}


