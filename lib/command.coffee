module.exports = (Matcher, behavior) ->
	return (matchingExpression, handler) ->
		behavior.matchers.push(new Matcher(matchingExpression, handler))


