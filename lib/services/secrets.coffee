module.exports = (configReader) ->
	configReader.ensureConfigDirExists()
	secrets = configReader.read("secrets.json")
	secretsPath = configReader.secretsFilePath

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

