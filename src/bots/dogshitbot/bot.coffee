console.log 'loading dogshitbot...'

class BotBehavior
	@match = (pattern, handler) ->
		matcher = {pattern, handler}
		@matchers ?= []
		@matchers.push(matcher)

	matchers: ->
		@constructor.matchers

	processMessage: (messageText) ->
		for matcher in @matchers()
			#console.log matcher.pattern
			{handler, pattern} = matcher
			if match = pattern.exec(messageText)
				handler.call(@, match)

	inject: (name, service) ->
		@[name] = service




#module.exports = 
class Dogshitbot extends BotBehavior

	@match(/zup/, (message) ->
		@say "see?"
	)
	@match(/cool/, (message) ->
		console.log message
		@say "HELL YEA!!!!!!"
	)
	foo: 2
	
module.exports = Dogshitbot

