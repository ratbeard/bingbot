module.exports = (Q, secrets) ->
	contacts = secrets.get("contacts")
	return {
		get: (username) ->
			for contact in contacts
				if contact.username == username
					return Q.resolve(contact)
			Q.reject("contact `#{username}` not found")
	}



