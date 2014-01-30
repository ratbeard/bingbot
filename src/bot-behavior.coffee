class Matcher
	constructor: (@pattern, @handler, @prefix) ->
		if typeof(@pattern) == "string"
			 @pattern = ///^#{@pattern}$///
		if @prefix
			@prefix = ///^#{@prefix}:?\s?///

	matches: (string) ->
		#console.log 'matches?', string, @prefix, @prefix.test(string)
		@match = null
		if @prefix
			return unless @prefix.test(string)
			string = string.replace(@prefix, '')
		@match = @pattern.exec(string)
		@match

	callHandler: (context) ->
		@handler.call(context, @match)

class BotBehavior
	constructor: (@botName) ->
		@matchers = []
		@pendingMessages = []

	#
	# Matching
	#
	match: (pattern, handler) ->
		@matchers.push(new Matcher(pattern, handler, null))
		@

	command: (pattern, handler) ->
		@matchers.push(new Matcher(pattern, handler, @botName))
		@

	#
	# Responding
	#
	say: (body) ->
		@pendingMessages.push(body)

	#
	# Events
	#
	onMessage: (message) ->
		for matcher in @matchers
			if matcher.matches(message.body)
				matcher.callHandler(@)
				return

module.exports = BotBehavior

