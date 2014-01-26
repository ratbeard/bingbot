module.exports = (random) ->
	class BlackjackGame
		@pips = '2 3 4 5 6 7 8 9 10 J Q K A'.split(' ')
		@suits = '♠ ♥ ♦ ♣'.split(' ')
		@deck = []
		for pip in @pips
			for suit in @suits
				@deck.push({pip, suit})

		constructor: ->
			@computersHand = []
			@playersHand = []
			@winner = null
			random.shuffle(BlackjackGame.deck)

		deal: ->
			@dealCardToComputer()
			@dealCardToPlayer()
			@dealCardToComputer()
			@dealCardToPlayer()

		dealCardToComputer: ->
			@computersHand.push(@dealCard())
			if @computersScore() == 21
				@winner = "computer"

		dealCardToPlayer: ->
			@playersHand.push(@dealCard())

		computersScore: () ->
			@scoreHand(@computersHand)

		playersScore: () ->
			@scoreHand(@playersHand)

		scoreHand: (hand) ->
			calculateScore = (areAcesHigh) ->
				hand.inject((total, card) => total + @score(card, areAcesHigh))
			score = calculateScore(true)
			if score > 21
				score = calculateScore(false)
			score


		score: ({pip}, areAcesHigh) ->
			return +pip if +pip
			return 11 if pip == 'A' && areAcesHigh
			return 1 if pip == 'A' && !areAcesHigh
			return 10



		dealCard: ->

		summary: ->
			"Dealer: [??] [5♥ ], Player: [A♥ ] [5♣']. 'hit me', 'stay', or 'split"


	return {
		BlackjackGame,

		flipCoin: ->
			if random.bool() then "heads" else "tails"

		rollDie: (numberOfSides) ->
			random(1, numberOfSides + 1)

		pick: (choices) ->
			random.pick(choices)
	}


