inject = (builder, locals={}) ->
	dependencyNames = inject.parseArgumentNames(builder)
	dependencies = for name in dependencyNames
		locals[name]
	builder(dependencies...)

inject.bot = (buildBehavior, locals={}) ->
	new buildBehavior(locals.command, locals.say)

# Arg parsing
functionDeclarationRegex = /^\s*function\s*\(([^)]*)/
blankRegex = /^\s*$/
commaRegex = /\s*,\s*/
inject.parseArgumentNames = (fn) ->
	argsString = fn.toString().match(functionDeclarationRegex)[1]
	return [] if blankRegex.test(argsString)
	argsString.split(commaRegex)

module.exports = inject

