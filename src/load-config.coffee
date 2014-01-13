createBingbotDir = ->

loadConfig = (environment) ->
	# if ! ~/.bingbot/, create it
	#
	# read in ~/.bingbot/config.json
	json = fs.read()

	# Merge in environment if specified.
	config = json.default
	if environment
		environmentConfig = json[environment]
		throw "No config for #{environment}" unless environmentConfig
		for k, v of environmentConfig
			config[k] = v
	config

module.exports = loadConfig

