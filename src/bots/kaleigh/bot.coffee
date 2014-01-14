BotBehavior = require('../../bot-behavior')

module.exports =
class Kaleigh extends BotBehavior
	@use 'api', 'users', 'contacts'

	@command
		match: /tell ([^\s]+) (.+)/, -> {user: match[0], messageText: match[1]}
		do: ({user, messageText}, {from}) ->
			if @users.include(user)
				@say "#{user}, #{from} said: '#{messageText}'"
			else
				@saveMessage({user, from, messageText})

	@command
		match: /txt ([^\s]+) (.+)/, -> {user: match[0], messageText: match[1]}
		do: ({user, body}) ->
			@contacts.get user, (contact) =>
				if !contact
					@say "#{from}, I don't know #{user}'s phone number"
					return
				@api.sendTextMessage(contact.phone, body, (err) =>
					@say "sent a text!"
				)

	saveMessage: (message) ->
		@store(message)
		@deliverOnConnect ?= @users.onConnect(@deliverAnySavedMessages)

	deliverAnySavedMessages: =>
			if messages = @store.findWhere({user})
				@say "#{user}, you have #{messages.length} messages:"
				for message in messages
					@say "#{message.from} said: '#{message.messageText}'"

		




if require.main == module
	bot = new Kaleigh
	bot.api = require('./api')
	bot.say = console.log
	bot.processMessage("hey there")


