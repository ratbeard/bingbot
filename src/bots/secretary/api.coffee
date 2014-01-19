module.exports = ($twilio, $contacts) ->
	error = (message, callback) ->
		console.error("ERROR", message)
		callback?(message)

	return {
		getPhoneNumber: (usernameOrPhoneNumber, callback) ->
			isPhoneNumber = /^\+\d+$/.test(usernameOrPhoneNumber)
			if isPhoneNumber
				callback(null, usernameOrPhoneNumber)
			else
				username = usernameOrPhoneNumber
				$contacts.get(username, (user) ->
					return error("Couldn't find user #{username}", callback) unless user
					return error("No `phone` set for `#{username}`", callback) unless user.phone
					callback(null, user.phone)
				)

		sendTextMessage: (usernameOrPhoneNumber, body, callback) ->
			@getPhoneNumber(usernameOrPhoneNumber, (err, phoneNumber) ->
				return error(err, callback) if err
				$twilio.sendTextMessage(phoneNumber, body, (err, message) ->
					callback?()
				)
			)
	}

# ====
services = {
	put: (name, builderFn) ->
		@[name] = builderFn

	get: (name) ->
		@[name] || @read(name)

	read: (name) ->
		console.log 'read:', name
		require("./services/#{name}")
}


services.put("$contacts", ($secrets) ->
	contacts = $secrets.get("contacts")
	return {
		get: (username, callback) ->
			for contact in contacts
				if contact.username == username
					return callback(contact)
			callback(null)
	}
)

services.put("$twilio", ($secrets) ->
	Twilio = require('twilio')

	[twillioSid, twillioToken, twillioPhoneNumber] = $secrets.get("twilio.sid", "twilio.token", "twilio.phoneNumber")
	twilio = Twilio(twillioSid, twillioToken)

	return {
		sendTextMessage: (to, body, callback) ->
			console.log('hey', to, from, body)
			from = twillioPhoneNumber
			twilio.sms.messages.create({body, to, from}, (err, message) ->
				console.log 'twillioResponse:', message, err
				callback?(err, message)
			)
	}
)

services.put("$secrets", ($config) ->
	$config.ensureConfigDirExists()
	secrets = $config.read("secrets.json")
	secretsPath = $config.secretsFilePath

	return {
		get: (keys...) ->
			missingKeys = []
			values = for key in keys
				secrets[key] || missingKeys.push(key)

			if missingKeys.length
				throw "Did not find secrets with keys `#{JSON.stringify(missingKeys)}` in `#{secretsPath}`"

			values = values[0] if values.length == 1
			values
	}
)

services.put("$config", () ->
	fs = require('fs')
	path = require('path')

	configDirPath = path.join(process.env.HOME, ".bingbot")
	configFilePath = path.join(configDirPath, "config.json")
	secretsFilePath = path.join(configDirPath, "secrets.json")
	copyFile = (srcPath, destPath) ->
		#fs.createReadStream(srcPath).pipe(fs.createWriteStream(destPath))
		fs.writeFileSync(destPath, fs.readFileSync(srcPath, 'utf8'))

	# TODO
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
)




if require.main == module
	injector = require('../../injector')
	api = injector.inject(module.exports, services)
	body = "sup dog?"
	to = "encryptd_fractal"
	api.sendTextMessage(to, body)


