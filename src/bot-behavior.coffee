module.exports =
class BotBehavior
	@match = (pattern, handler) ->
		matcher = {pattern, handler}
		@matchers ?= []
		@matchers.push(matcher)

	@use = (dependencies...) ->
		@dependencies = dependencies

	matchers: ->
		@constructor.matchers

	processMessage: (messageText) ->
		for matcher in @matchers()
			#console.log matcher.pattern
			{handler, pattern} = matcher
			if match = pattern.exec(messageText)
				handler.call(@, match)

