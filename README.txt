Bots
====
Development setup instructions (OSX):

		npm install

Running the bot repl:

		coffee src/repl.coffee

Useful commands inside repl:

		bots

		dogshitbot.connect()
		dogshitbot.disconnect()
		dogshitbot.say("sup guys")
		dogshitbot.reload()   				// reloads behavior, stays connected in channel


To generate a bot:

		# one time setup
		cd generators/generator-bot
		npm link 
		cd ../..

		yo bot coolbot


scratchpad
=======
To run the repl and have it reload on file change:

		npm install -g nodemon
		nodemon src/repl.coffee

To add a package and save to package.json:
		npm install underscore --save   (or --save-dev)


TODO
====

- botName based on actual name in chatroom for commands


