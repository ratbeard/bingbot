escapeRegex = (string) ->
  return new RegExp(string.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"))

module.exports = class Matcher
	@inject = false
	constructor: (matchExpression, @handler) ->
		@matchRegex =
			if typeof matchExpression == 'string'
				escapeRegex(matchExpression)
			else if matchExpression instanceof RegExp
				matchExpression

	doesMatch: (messageBody) ->
		!!@matchRegex.exec(messageBody)

