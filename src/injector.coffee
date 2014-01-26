services = {
	#put: (name, builderFn) ->
		#@[name] = builderFn

	get: (name, context) ->
		#@[name] || @read(name, context)
		console.log 'get', name, context
		context[name] || @read(name, context)

	read: (name, context) ->
		if name == "$api"
			require("./bots/#{context.botName()}/api")
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

	inject:(fn, context={}) ->
		instantiatedServices = for name in @argumentNames(fn)
			buildFn = context[name] || services.get(name, context)
			# TODO - handle circular dependencies
			@inject(buildFn, context)
		fn.apply(null, instantiatedServices)

	bot: (botName) ->
		context = {botName: -> botName}
		behaviorFn = require("./bots/#{botName}/bot.coffee")
		@inject(behaviorFn, context)
}

module.exports = {injector, services}

if require.main == module
	fn0 = (arg) ->
	fn1 = (a, b_c2, $Ho$t) ->
	fn2 = () ->
	fn3 = (uhoh...) -> 'this doesnt work :('
	console.log JSON.stringify(injector.argumentNames(fn0))
	console.log JSON.stringify(injector.argumentNames(fn1))
	console.log JSON.stringify(injector.argumentNames(fn2))
	console.log JSON.stringify(injector.argumentNames(fn3))

