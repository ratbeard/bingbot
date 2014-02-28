escapeRegex = (string) ->
  return new RegExp(string.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"))

module.exports = class Matcher
	@inject = false
	constructor: (matchExpression, @handler) ->
		@pattern =
			if typeof matchExpression == 'string'
				escapeRegex(matchExpression)
			else if matchExpression instanceof RegExp
				matchExpression

	doesMatch: (message) ->
		@pattern.test(message.body)

	match: (message) ->
		string = message.body
		match = null
		if @prefix # pop off prefix
			return unless @prefix.test(string)
			string = string.replace(@prefix, '')
		@pattern.exec(string)

