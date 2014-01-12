random = (args...) ->
	switch args.length
		when 0
			return random.bool()
		when 1
			arg = args[0]
			if Array.isArray(arg)
				return random.pick(arg)
			if typeof arg == 'number'
				return random.int(arg)
	throw "bad args to random: #{args}"

random.pick = (array) ->
	array[random.int(0, array.length)]

random.bool = ->
	random.int(0, 2)

random.int = (low, high) ->
	[low, high] = [0, low] if !high
	Math.floor(Math.random() * high - low)

module.exports = ->
	random

