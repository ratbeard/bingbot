injector = {
	getDependency: (name) ->
		console.log 'getDependency', name
		require("./services/#{name}.coffee")()

	argumentNames: (fn) ->
		functionDeclarationRegex = /^\s*function\s*\(([^)]*)/
		blankRegex = /^\s*$/
		commaRegex = /\s*,\s*/
		argsString = fn.toString().match(functionDeclarationRegex)[1]
		return [] if blankRegex.test(argsString)
		argsString.split(commaRegex)

	buildBotBehavior: (bot) ->
		{name} = bot
		klass = require("./bots/#{name}/bot.coffee")
		behavior = new klass()

		behavior.api = require("./bots/#{name}/api.coffee")
		dependencies = [].concat(klass.dependencies ? [])
		for dependency in dependencies
			behavior[dependency] = @getDependency(dependency)(bot)
		bot.behavior = behavior

	inject:(fn, registry={}) ->
		services = for name in @argumentNames(fn)
			registry[name] || @getDependency(name)
		fn.apply(null, services)
}

module.exports = injector

if require.main == module
	fn0 = (arg) ->
	fn1 = (a, b_c, Hot) ->
	fn2 = () ->
	fn3 = (uhoh...) -> 'this doesnt work'
	console.log JSON.stringify(injector.argumentNames(fn0))
	console.log JSON.stringify(injector.argumentNames(fn1))
	console.log JSON.stringify(injector.argumentNames(fn2))
	console.log JSON.stringify(injector.argumentNames(fn3))

