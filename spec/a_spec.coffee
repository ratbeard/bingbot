_ = require('underscore')
inject = require('../lib/inject')
command = require('../lib/command')
Matcher = require('../lib/matcher')

#
# Implementations
#
ActiveBots = ->
	return @instance if @instance
	@bots = []
	@instance = @

MessageQueue = inject((ActiveBots) ->
	return {outgoing: []}
, {ActiveBots})
MessageQueue.singleton = true

say = inject((MessageQueue) ->
	return (body) ->
		#console.log 'saying!!!!!', body
		MessageQueue.outgoing.push(body)
, {MessageQueue})
say.inject = false

#
behaviorServices = {command, say, Matcher}
class Behavior
	constructor: (builder, locals) ->
		@matchers = []
		locals = _.extend({}, behaviorServices, {behavior: @}, locals)
		return inject(builder, locals)

	onMessage: (message) ->
		for matcher in @matchers
			if matcher.doesMatch(message.body)
				matcher.handler()

#
# Low level functional tests
describe "inject", ->
	describe "inject(builder, locals)", ->
		it "builder is given objects from `locals`, based on its function argument names", ->
			locals = {a: 'a', b: 'b', c: 'c'}
			builder = (b, a) ->
				expect(a).toEqual('a')
				#expect(b).toEqual('b')
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
			expect(new Matcher("cry").doesMatch("go cry")).toBe(true)
			expect(new Matcher("cry").doesMatch("big road")).toBe(false)
			expect(new Matcher("cry").doesMatch("@crybaby shut up")).toBe(true)
			expect(new Matcher("cry").doesMatch("@Crybaby shut up")).toBe(false)

	describe "when given a regex", ->
		it "matches if the regex matches", ->
			expect(new Matcher(/cr?y/).doesMatch("go cry")).toBe(true)
			expect(new Matcher(/cr?y/).doesMatch("go cyhi")).toBe(true)
			expect(new Matcher(/cr?y/).doesMatch("go Cry chrys")).toBe(false)


#
# High level tests		
#
describe "Behavior", ->
	registry = {MessageQueue}
	greetBehavior = new Behavior((command, say) ->
		command "hello", -> say("hi")
	, registry)

	it "registers messages to match against", ->
		expect(greetBehavior.matchers.length).toBe(1)

	it "says things back to the chatroom", ->
		greetBehavior.onMessage({body: "hello"})
		greetBehavior.onMessage({body: "oh hello"})
		greetBehavior.onMessage({body: "bye"})
		expect(MessageQueue.outgoing.length).toBe(2)
		expect(MessageQueue.outgoing).toEqual(["hi", "hi"])


describe "MessageQueue", ->
	it "is a singleton", ->
	it "requires a list of bots and the master connection", ->
	it "forwards incoming messages to each active bot", ->
	it "takes outgoing messages from behaviors and sends them through the bots connection to the chatroom", ->
	it "can apply a filter to the body of an incomming message", ->


describe "Connection", ->
	it "", ->


describe "Bot", ->
	it "contains a connection, behavior, and name", ->
	it "can reload a behavior", ->


describe "master connection", ->
	it "forwards a message to the MessageQueue upon hearing a message", ->



describe "declaring a bot", ->
	it "requires a behavior and an api", ->
	it "injects the correct api in to the behavior", ->


describe "services", ->
	describe "random", ->
		describe "flip()", ->
		describe "roll()", ->

