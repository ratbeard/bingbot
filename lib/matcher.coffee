escapeRegex = (string) ->
  return new RegExp(string.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"))

module.exports = class Matcher
	constructor: (matchExpression) ->
		@matchRegex =
			if typeof matchExpression == 'string'
				escapeRegex(matchExpression)
			else if matchExpression instanceof RegExp
				matchExpression

	doesMatch: (messageBody) ->
		!!@matchRegex.exec(messageBody)

