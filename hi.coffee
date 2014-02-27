irc = require('irc')

irc = new irc.Client('my.local', 'dum',
	channels: ['#junkyard'],
	debug: true
)
irc.on('error', (err) ->
	console.log 'fuk', err
)
irc.on('connect', ->
	setInterval(->
		irc.say('#junkyard', 'hi')
	, 3000)
)

	

