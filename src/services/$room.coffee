module.exports = ($connection) ->
	
	# Track users in the chatroom
	names = []
	onNames =  (newNames) ->
		console.log 'got names!', newNames
		for username in newUsers
			for callback in onUserJoinCallbacks
				callback(username)

	requestNames = ->
		#$connection.send("names")

	#$connection.on("names", onNames)

	# TODO wait till connected...
	setInterval(requestNames, 10000)

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
