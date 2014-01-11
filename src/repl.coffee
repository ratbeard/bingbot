fs = require('fs')

# Reloading modules from the repl in Node.js
# Benjamin Gleitzman (gleitz@mit.edu)
#
# Inspired by Ben Barkay
# http://stackoverflow.com/a/14801711/305414
#
# Usage: `node reload.js`
# You can load the module as usual
# var mymodule = require('./mymodule')
# And the reload it when needed
# mymodule = require.reload('./mymodule')
#
# I suggest using an alias in your .bashrc/.profile:
# alias node_reload='node /path/to/reload.js'
repl = require("repl").start({})

###
Removes a module from the cache.
###
repl.context.require.uncache = (moduleName) ->
  
  # Run over the cache looking for the files
  # loaded by the specified module name
  repl.context.require.searchCache moduleName, (mod) ->
    delete require.cache[mod.id]

###
Runs over the cache to search for all the cached files.
###
repl.context.require.searchCache = (moduleName, callback) ->
  
  # Resolve the module identified by the specified name
  mod = require.resolve(moduleName)
  
  # Check if the module has been resolved and found within
  # the cache
  if mod and ((mod = require.cache[mod]) isnt `undefined`)
    
    # Recursively go over the results
    (run = (mod) ->
      
      # Go over each of the module's children and
      # run over it
      mod.children.forEach (child) ->
        run child

      
      # Call the specified callback providing the
      # found module
      callback mod
    ) mod


#
# * Load a module, clearing it from the cache if necessary.
# 
repl.context.require.reload = (moduleName) ->
  repl.context.require.uncache moduleName
  repl.context.require moduleName

repl.context.reload = (bot=null) ->
	console.log 'Reloading!'
	clearRequireCache()
	botsToReload = if bot then [bot] else connectedBots()
	for bot in botsToReload
		loadBot(bot)

clearRequireCache = ->
	require.cache = {}

repl.context.bots = {}

loadBot = (name) ->
	botDelegate = new BotDelegate(name)
	botDelegate.bot = require("../bots/#{name}/bot.coffee")
	repl.context.bots[name] = botDelegate
	repl.context[name] = botDelegate
	repl.context.d = botDelegate if name == 'dogshitbot'

connectedBots = ->
	[]

findBots = ->
	fs.readdir("../bots", (err, botNames) ->
		throw err if err
		loadBot(name) for name in botNames
	)

# init
findBots()

class BotDelegate
	constructor: (@name) ->
	join: ->
		console.log 'join'
	kick: ->
		console.log 'kick'
	reload: ->
		loadBot(@)
