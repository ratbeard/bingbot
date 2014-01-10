{Bot} = require 'bangbot'
{api} = require 'api'

class Scorpio extends Bot
	
	@match
		name: "createScore"
		description: "Award points to a thing, with an optional reason"
		pattern: /([+-]\d+) ([^\s]+)(?: for (.+))?/
		examples: [
			"+1 sprout"
			"-17 griswold for decrepit attitude"
		]
		handle: (message, [points, thing, reason]) ->
			awaredBy = message.saidBy
			createdAt = Time.now()
			api.createScore({points, thing, reason, awardedBy, createdAt})


	@match
		name: "printScore"
		description: "Print the score for a thing"
		pattern: /score ([^\s]+)( -r( *\d+)?)?/
		handle: (message, [thing, wantsReason, reasonCount]) ->
			if wantsReason
				reasonCount = _.restrictNumber(reasonCount, 0, 20)
			 
			api.scoreTotal({thing, reasonCount}, ({total, reasons}) =>
				formatReason = ({points, reason}) ->
					"#{points} points for #{reason}"

				response = "#{thing} has #{total} points "
				response += responses.map(formatReason).join(', ')
				@say response
			)





