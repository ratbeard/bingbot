module.exports = ->
	class Matcher
		constructor: (@pattern, @handler) ->

		matches: (string) ->
			@match = @pattern.exec(string)

		callHandler: (context) ->
			@handler.call(context, @match)

	class BotBehavior
		constructor: ->
			@matchers = []
			@pendingMessages = []

		match: (pattern, handler) ->
			@matchers.push(new Matcher(pattern, handler))

		say: (body) ->
			@pendingMessages.push(body)

		onMessage: (messageText) ->
			for matcher in @matchers
				if matcher.matches(messageText)
					matcher.callHandler(@)
					return

	return new BotBehavior()

