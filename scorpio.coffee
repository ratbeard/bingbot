irc         = require 'irc'
$           = require 'jquery'
connect     = require 'connect'
mongo       = require 'mongodb'

class Scorpio

  constructor : (options) ->
    @options          = $.extend(@defaults, options)
    @mainApp          = $( @options.mainAppPage )
    @botName          = @options.bot_name
    @appID            = @options.app_name
    @appSecret        = @options.app_secret
    @chatChannel      = [ @options.irc_channel ]

    #database configs
    @database         = null
    @dbCollection     = ['users','score']
    @databasePort     = @options.app_port

    # inti the new scorpio!
    @_init()

  clearScores: =>
    return

  #getCollection: =>
    #@database.collection('users', (callback) =>
      #if (error)
        #@_handleError(error)
      #else

  ## will loop through the fields and get the users
  getScores: (query) =>
    

  addUser: (user, value) =>
    console.log "Adding user #{user} in the database"
    @dbCollection.insert({"_user": user, "points": value }, (error, inserted) =>
      if (error) then @_handleError(error)
    )


  setUserScore: (user, currScore, newScore) =>
    console.log "SETTING NEW SCORE FOR #{user}, OLD SCORE: #{currScore}, NEW SCORE: #{newScore}"
    @dbCollection.update("_user":"#{user}",{$set: {"points": newScore}}, (error, cb) =>
      if (error) then @_handleError(error)
    )


  findUserScore: (user, value) =>
    console.log "user #{user} exists in the db"

    val = parseInt(value)
    currScore = null
    newScore = null

    @dbCollection.findOne("_user":"#{user}", (error, userCallback) =>
      if (error)
        @_handleError(error)
      else
        #we need to get the value of user_field and update it
        if (userCallback.points)
          console.log "WE FOUND USER #{user} DATA: #{userCallback.points}"
          currScore = userCallback.points
          newScore = (currScore += value)
          @setUserScore(user, currScore, newScore)
    )

    #@dbCollection.update("_user" : "#{user}", {$set : {"points":"#{val}"

    #@dbCollection.findOne( 
      #if (error)
        #@_handleError(error)
      #else
        
    #)
    

  addScore: (user, value) =>
    userData = user
    # Get the Name of the user against the db
    @dbCollection.findOne( "_user":"#{userData}", (error, userCallback) =>
      if userCallback is null
        # if user doesnt exist in the db add them
        @addUser(userData, value)
      else
        # else if user exists in the db update their score with the new int
        @findUserScore(userData, value)
    )

  sayScore: (from, to, user) =>
    @dbCollection.findOne("_user":"#{user}", (error, userCallback) =>
      if (error)
        @_handleError(error)
      else
        if (!userCallback)
          # if the user doesnt exist we cant tell any scores
          msg = "#{user} has no points"
          return
        if (userCallback.points)
          # if the user has score we can print the score
          score = userCallback.points
          msg = "#{user} has #{score} points"
          @bot.say to, msg
        else
          msg = "#{user} has no points"
          @bot.say to, msg
    )

  sayScores: (from, to) =>
    @dbCollection.find().toArray((err, results)  =>
      msg = for scores in results
        userScore = scores.points
        userName = scores._user
        "#{userName} has #{userScore} points"

      msg = msg.join(", ")
      @bot.say(to, msg)

    )

  _handleError: (message) =>
    # quality error handling 
    # +1 darkcypher_bit (aka. ratfuk, encrypted_fractal, COMPUTER_HOBBY)
    console.log "fuk #{message}"

  _connectBot: =>
    @bot = new irc.Client('irc.freenode.net', "#{@botName}",
      debug: true,
      channels: @chatChannel
    )

    ## initialize the bot listeners
    @_initListeners()

  _initListeners: =>
    # Listen to new messages for addings and removing points 
    @bot.addListener 'message', (from, to, message) =>
      console.log('%s => %s: %s', from, to, message)

      @dbCollection.remove( "points" : 0, (error, callback) =>
        if (error) then @_handleError(error)
      )

      if match = message.match(/([+-]\d+)\s+(\S+)/)
        [_, score, user] = match
        score = parseInt(score)

        @addScore(user, score)

      else if match = message.match /score (\S+)/

        user = match[1]
        @sayScore(from, to, user)
      
      else if message.match /whats the score/

        @sayScores(from, to)


    # Something has gone wrong :(
    @bot.addListener 'error', (message) ->
      @_handleError(message)

  _connectDb: =>
    mongoQuery = "mongodb://#{@appID}:#{@appSecret}.mongolab.com:#{@databasePort}/#{@appID}"
    mongoUri = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || mongoQuery
    
    console.log "~~~!! CONNECTING TO DB !!~~~~"
    mongo.connect( mongoUri, @dbCollection, @_dbConnectCallback )


  _dbConnectCallback: (error, db) =>
    console.log 'CONNECTED TO MONGODB', db

    @database = db
    @dbModel = @database
    @database.addListener( "error", @_handleError )

    @database.collection('users', (error, callback) =>
      if (error)
        @_handleError(error)
      else
        @dbCollection = @database.collection('users')
        @_connectBot()
    )
    #creates collection of users
    
    #@database.createCollection('users',  (error, collection) =>
      #if error
        #@_handleError(error)
      #else
        #collection.insert( {"test":"value"}, (error, inserted) =>
          #if (error) then @_handleError(error)
        #)
        #collection.findOne( 'users' : 'users' , (error, doc) =>
          #console.log "good to go\n\n\n\n\n\n",  @database
        #)
    #)

    ## since the database exists now, connect the bot to IRC
    #@_connectBot()


  _init: =>
    @_connectDb()

bot = new Scorpio(
  bot_name: 'scorpio',
  irc_channel: '#coolkidsusa',
  app_name: 'heroku_app16378963',
  app_secret: 's8en8qk8u2jnhg31to2v7o4fq0@ds031608',
  app_port: '31608'
)
