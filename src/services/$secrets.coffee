module.exports = ($config) ->
	$config.ensureConfigDirExists()
	secrets = $config.read("secrets.json")
	secretsPath = $config.secretsFilePath

	return {
		get: (keys...) ->
			missingKeys = []
			values = for key in keys
				secrets[key] || missingKeys.push(key)

			# TODO
			if missingKeys.length
				throw "Did not find secrets with keys `#{JSON.stringify(missingKeys)}"

			values = values[0] if values.length == 1
			values
	}
