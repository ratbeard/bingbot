inject = require('../lib/inject')
commandBuilder = require('../lib/command')
Matcher = require('../lib/matcher')

boringBotBehavior = (command, say) ->
	command "hello", ->
		say("hi")


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
		

describe "building a bot", ->
	it "asks for dependencies to be inject", ->
		locals =
			command: ->
			say: ->
		spyOn(locals, 'command')
		inject.bot(boringBotBehavior, locals)
		expect(locals.command).toHaveBeenCalled()

describe "command service", ->
	it "creates a new matcher object and hands it off", ->
		matchers = []
		matcher = ->
		matcherAccepter = (matcher) -> matchers.push(matcher)
		command = commandBuilder(matcher, matcherAccepter)
		command("hello", ->)
		expect(matchers.length).toEqual(1)

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
