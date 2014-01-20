module.exports = ->
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
			when 2
				return random.int(args[0], args[1])
		throw "bad args to random: #{args}"

	random.pick = (array) ->
		array[random.int(0, array.length)]

	random.bool = ->
		!!random.int(0, 1)

	random.int = (min, max) ->
		[min, max] = [0, min] if !max
		Math.floor(Math.random() * (max - min) + min)

	random.shuffle = `
		function shuffle(o){
				for(var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
				return o;
		}
	`
		

	return random

