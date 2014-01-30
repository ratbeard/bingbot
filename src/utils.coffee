module.exports = {
	error: (message, e) ->
		m = "\n#{message}".red.bold
		m += ":\n#{e}".red if e
		console.error(m)

	extend: (target, source) ->
		for k, v of source
			target[k] = v
		target
}

