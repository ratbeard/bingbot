#
# Basic injection
#
inject = (builder, locals={}) ->
	#console.error('INJECT', builder.toString(), locals)
	dependencyNames = inject.parseArgumentNames(builder)
	dependencies = for name in dependencyNames
		dependency = locals[name] ? throw new Error("Could not find dependency: `#{name}`.\n\tAvailable: `#{Object.keys(locals).join(', ')}`.\n\tFunction: #{builder}")
		#console.log name, dependency, locals
		if typeof dependency == 'function' && dependency.inject != false
			shouldSave = dependency.singleton
			dependency = inject(dependency, locals)
			if shouldSave
				locals[name] = dependency

		dependency
	new builder(dependencies...)

functionDeclarationRegex = /^\s*function[^(]*\(([^)]*)/
blankRegex = /^\s*$/
commaRegex = /\s*,\s*/

inject.parseArgumentNames = (fn) ->
	#console.error('!!', fn.toString()) if !fn.toString().match(functionDeclarationRegex)
	argsString = fn.toString().match(functionDeclarationRegex)[1]
	return [] if blankRegex.test(argsString)
	argsString.split(commaRegex)

#
# Specialized injection
#
inject.bot = (buildBehavior, locals={}) ->
	new buildBehavior(locals.command, locals.say)

module.exports = inject

