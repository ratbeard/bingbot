module.exports = () ->
	fs = require('fs')
	path = require('path')

	configDirPath = path.join(process.env.HOME, ".bingbot")
	configFilePath = path.join(configDirPath, "config.json")
	secretsFilePath = path.join(configDirPath, "secrets.json")
	copyFile = (srcPath, destPath) ->
		#fs.createReadStream(srcPath).pipe(fs.createWriteStream(destPath))
		fs.writeFileSync(destPath, fs.readFileSync(srcPath, 'utf8'))

	return {
		configDirPath, configFilePath, secretsFilePath,

		ensureConfigDirExists: ->
			if !fs.existsSync(configDirPath)
				console.log("""ヽ༼ຈل͜ຈ༽ﾉ `#{configDirPath}` not found!!  I'll make it for you.""")
				fs.mkdirSync(configDirPath)

			if !fs.existsSync(configFilePath)# || 1
				console.log("""... creating #{configFilePath}""")
				copyFile(path.join(__dirname, "../../templates/config.json"), configFilePath)

			if !fs.existsSync(secretsFilePath)# || 1
				console.log("""... creating #{secretsFilePath}""")
				copyFile(path.join(__dirname, "../../templates/secrets.json"), secretsFilePath)

		path: (filename) ->
			path.join(process.env.HOME, ".bingbot", filename)

		read: (filename) ->
			p = @path(filename)
			jsonString = fs.readFileSync(p, 'utf8')
			JSON.parse(jsonString)
	}


