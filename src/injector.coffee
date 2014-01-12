injector = {
	getDependency: (name) ->
		require("./services/#{name}.coffee")

	buildBotBehavior: (bot) ->
		{name} = bot
		klass = require("./bots/#{name}/bot.coffee")
		behavior = new klass()

		behavior.api = require("./bots/#{name}/api.coffee")
		dependencies = ['say'].concat(klass.dependencies ? [])
		for dependency in dependencies
			behavior[dependency] = @getDependency(dependency)(bot)
		bot.behavior = behavior
}

module.exports = injector

