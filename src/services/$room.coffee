module.exports = ($connection) ->
	
	# Track users in the chatroom
	names = []
	onNames =  (newNames) ->
		console.log 'got names!', newNames

	requestNames = ->
		$connection.send("names")
		for username in newUsers
			for callback in onUserJoinCallbacks
				callback(username)

	$connection.addListener("names", onNames)
	setInterval(requestNames, 1000)

	userJoinCallbacks = []

	return {
		user: (username) ->
			for name in names
				return name if username == name
			return null

		onUserJoin: (callback) ->
			userJoinCallbacks.push(callback)
	}


if require.main == module
	console.log 'kel'
