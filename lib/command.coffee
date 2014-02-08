module.exports = (matcherBuilder, matcherAcceptor) ->
	return (matchingExpression) ->
		matcherAcceptor(new matcherBuilder(matchingExpression))


