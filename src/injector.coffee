services = {
	put: (name, builderFn) ->
		@[name] = builderFn

	get: (name, context) ->
		@[name] || @read(name, context)

	read: (name, context) ->
		console.log 'read:', name
		if name == "$api"
			require("./bots/#{context.botName}/api")
		else
			require("./services/#{name}")
}

injector = {
	argumentNames: (fn) ->
		functionDeclarationRegex = /^\s*function\s*\(([^)]*)/
		blankRegex = /^\s*$/
		commaRegex = /\s*,\s*/
		argsString = fn.toString().match(functionDeclarationRegex)[1]
		return [] if blankRegex.test(argsString)
		argsString.split(commaRegex)

	inject:(fn) ->
		context = { botName: "secretary" }
		instantiatedServices = for name in @argumentNames(fn)
			buildFn = services.get(name, context)
			# TODO - handle circular dependencies
			@inject(buildFn, services)
		fn.apply(null, instantiatedServices)
}

module.exports = {injector, services}

if require.main == module
	fn0 = (arg) ->
	fn1 = (a, b_c, Hot) ->
	fn2 = () ->
	fn3 = (uhoh...) -> 'this doesnt work'
	console.log JSON.stringify(injector.argumentNames(fn0))
	console.log JSON.stringify(injector.argumentNames(fn1))
	console.log JSON.stringify(injector.argumentNames(fn2))
	console.log JSON.stringify(injector.argumentNames(fn3))

