{inject, say, command, Bot, Connection, Matcher, Behavior, MessageQueue, ActiveBots, Session} = require('../lib/core')

#
# Implementations
#
#
# Low level functional tests
#
describe "inject", ->
	describe "inject(builder, locals)", ->
		it "builder is given objects from `locals`, based on its function argument names", ->
			locals = {a: 'a', b: 'b', c: 'c'}
			builder = (b, a) ->
				expect(a).toEqual('a')
				expect(b).toEqual('b')
			inject(builder, locals)

	describe "inject.parseArgumentNames(fn)", ->
		it "works", ->
			expect(inject.parseArgumentNames(() ->)).toEqual([])
			expect(inject.parseArgumentNames((arg) ->)).toEqual(["arg"])
			expect(inject.parseArgumentNames((a, b_c2, $Ho$t) ->)).toEqual(["a", "b_c2", "$Ho$t"])

		it "can't parse splat args", ->
			expect(inject.parseArgumentNames((args...) ->)).toEqual([])


	it "only calls a singleton service once", ->
		count = 0
		GlobalCounter = () -> count++
		GlobalCounter.singleton = true
		registry = {GlobalCounter}
		inject((GlobalCounter) ->
			7
		, registry)
		inject((GlobalCounter) ->
			7
		, registry)
		expect(count).toBe(1)

	it "calls a non-singleton service multiple times", ->
		count = 0
		Counter = () -> count++
		registry = {Counter}
		inject((Counter) ->
			7
		, registry)
		inject((Counter) ->
			7
		, registry)
		expect(count).toBe(2)
		
		

describe "Matcher", ->
	describe "when given a string", ->
		it "matches if the string is present", ->
			expect(new Matcher("cry").doesMatch(body: "go cry")).toBe(true)
			expect(new Matcher("cry").doesMatch(body: "big road")).toBe(false)
			expect(new Matcher("cry").doesMatch(body: "@crybaby shut up")).toBe(true)
			expect(new Matcher("cry").doesMatch(body: "@Crybaby shut up")).toBe(false)

	describe "when given a regex", ->
		it "matches if the regex matches", ->
			expect(new Matcher(/cr?y/).doesMatch(body: "go cry")).toBe(true)
			expect(new Matcher(/cr?y/).doesMatch(body: "go cyhi")).toBe(true)
			expect(new Matcher(/cr?y/).doesMatch(body: "go Cry chrys")).toBe(false)


#
# High level tests		
#
describe "Behavior", ->
	builder = (command, say) ->
		command "hello", -> say("hi")
	behavior = new Behavior
	messages = new MessageQueue
	botName = 'greeter'
	greetBehavior = inject.core(builder, {behavior, messages, botName})

	it "registers messages to match against", ->
		expect(behavior.matchers.length).toBe(1)


describe "Connection", ->
	it "asks for irc config", ->


describe "connecting a Bot to the chatroom", ->
	registry = {MessageQueue}
	greetBehavior = new Behavior((command, say) ->
		command "hello", -> say("hi")
	, registry)


	xit "works", ->
		connection = createSpyObj('connection', ['connect'])
		bot = new Bot('greeter', connection, greetBehavior)
		bot.connect()
		expect(connection.connect).toHaveBeenCalled()
	



describe "starting a session", ->
	#session = null
	#beforeEach ->
		#config = {read: -> {a:1}}
		#session = inject.core(Session, {config})

	#it "finds available bots in the bots/ dir", ->
		#botNames = session.botNames
		#expect(botNames).toContain('masterbot')
		#expect(botNames).toContain('kaleigh')

	#it "instantiates a Bot for each available bot", ->
		#expect(session.bots.masterbot.connect).toBeTruthy()

	#it "reads in config and merges it in to itself", ->
		#expect(session.config.a).toBe(1)

	it "it tells masterbot to connect", ->

	it "it connects other startup bots", ->


describe "when a message is said in the room", ->


describe "MessageQueue", ->
	it "is a singleton", ->
	it "requires a list of bots and the master connection", ->
	it "forwards incoming messages to each active bot", ->
	it "takes outgoing messages from behaviors and sends them through the bots connection to the chatroom", ->
	it "can apply a filter to the body of an incomming message", ->



describe "Bot", ->
	it "contains a connection, behavior, and name", ->
	it "can reload a behavior", ->


describe "master connection", ->
	it "forwards a message to the MessageQueue upon hearing a message", ->



describe "declaring a bot", ->
	it "requires a behavior and an api", ->

	it "injects the correct api in to the behavior", ->


#
# Low level services
#
describe "services", ->
	describe "random", ->
		it "werks", ->
			random = inject(require('../src/services/random'), {})
			x = random(3, 4)
			# hmm is this right?
			expect(x).toBeLessThan(3.1)
			expect(x).toBeGreaterThan(2.9)


#
# TDD KALEIGH
#

FakeIrcClientFactory = ->
	class FakeIrcClient
		constructor: (@server, @channel, @botName) ->
			@responses = []

		on: (eventName, callback) ->
			console.log "FakeClient", "registered listener for #{eventName}"

		connect: ->
			console.log "FakeClient", "connect!"

		say: (body) ->
			@responses.push(body)

	return {
		build: (args...) ->
			new FakeIrcClient(args...)
	}


createTestSession = () ->
	defaults = {
		config: {}
		IrcClientFactory: FakeIrcClientFactory
	}
	session = inject.core(Session, defaults)
	session.sayInChatroom = (body) ->
		from = 'someone'
		session.messages.addIncoming({from, body})
	# TODO - wrong level of abstraction.  responses should go on a queue, not directly to connection?
	session.responses = ->
		session.bots.kaleigh.connection.client.responses
	session

makeBotApi = (botName) ->
	apiBuilder = require("../lib/bots/#{botName}/api")
	api = inject.core(apiBuilder)

describe "kaleigh", ->
	describe "behavior", ->
		it "responds to 'hi'", ->
			# TODO - tell kaleigh to launch
			session = createTestSession()
			session.sayInChatroom("kaleigh: hi")
			expect(session.responses().length).toBe(1)
			expect(session.responses()[0]).toBe("hello")

		describe "'txt' command", ->
			it "matches a phone number", ->
				kaleighBehavior = createTestSession().bots.kaleigh.behavior
				expectMatch = (body, shouldMatch=true) ->
					expect(kaleighBehavior.doesMatch({body})).toBe(shouldMatch)

				expectMatch "kaleigh: txt 1112223333 sup dog"
				expectMatch "kaleigh: txt cuco sup dog"
	
	describe "api", ->
		api = makeBotApi("kaleigh")

		describe "normalizePhoneNumber()", ->
			describe "given a full twilio expected number", ->
				it "returns it", ->
					expect(api.normalizePhoneNumber("+12223334444")).toBe("+12223334444")
			describe "given a shorthand number", ->
				it "converts it to a full number", ->
					expect(api.normalizePhoneNumber("2223334444")).toBe("+12223334444")
					expect(api.normalizePhoneNumber("222-333-4444")).toBe("+12223334444")
			describe "given something thats not a phone number", ->
				it "returns null", ->
					expect(api.normalizePhoneNumber("cuco")).toBe(null)
					expect(api.normalizePhoneNumber(null)).toBe(null)


