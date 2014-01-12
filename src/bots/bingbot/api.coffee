cheerio = require('cheerio')
request = require('request')

bing =
	topResult: (phrase, callback) ->
		@webSearch(phrase, (results) ->
			callback(results[0])
		)

	webSearch: (phrase, callback) ->
		url = "http://www.bing.com/search?q=#{encodeURIComponent(phrase)}"
		onError = -> callback(["ヽ༼ຈل͜ຈ༽ﾉ soRry bro!  bing must be down"])

		parseResultsHtml = (err, response, body) ->
			return onError() if err
			$ = cheerio.load(body)
			results = $('.sa_mc > p').map(-> $(@).text())
			if results.length
				callback(results)
			else
				onError()

		request.get(url, parseResultsHtml)

module.exports = bing

if require.main == module
	logTopResult = (phrase) ->
		bing.topResult(phrase, (r) -> console.log("#{phrase}: #{r}"))
	logTopResult('cash cats')
	logTopResult('dece beer')
	logTopResult('adsjfk as jklfasd iorfewq jdaiscosf dsafjioad fdijfdif 90 90 90 90 90 90 i dunno ?!!! ??! @#$adsf')

