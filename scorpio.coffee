irc         = require 'irc'
$           = require 'jquery'
connect     = require 'connect'
mongo       = require 'mongodb'

class Scorpio

  constructor : (options) ->
    @options          = $.extend(@defaults, options)
    @botName          = @options.bot_name
    @appID            = @options.app_name
    @appSecret        = @options.app_secret
    @chatChannel      = [ @options.irc_channel ]

    #database configs
    @database         = null
    @dbCollection     = null
    @databasePort     = @options.app_port

    # inti the new scorpio!
    @_init()

  clearScores: =>
    @dbCollection.remove( "points" : 0, (error, callback) =>
      if (error) then @_handleError(error)
    )


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
          #console.log "WE FOUND USER #{user} DATA: #{userCallback.points}"
          currScore = userCallback.points
          newScore = (currScore += value)
          @setUserScore(user, currScore, newScore)
    )

  addScore: (user, value) =>
    userData = user
    console.log "ADDING SCORE FOR #{user}"

    unless user.indexOf("http://") is -1
      user = user.replace('http://', '')
      console.log user

    unless user.indexOf("https://") is -1
      user = user.replace('https://', '')
      console.log user

    # Get the Name of the user against the db
    @dbCollection.findOne( "_user":"#{userData}", (error, userCallback) =>
      if userCallback is null
        # if user doesnt exist in the db add them
        @addUser(userData, value)
      else
        # else if user exists in the db update their score with the new int
        @findUserScore(userData, value)
    )

  findScores: (from, to, order) =>

    if order is 'ascending'
      orderBy = -1
    else
      orderBy = 1

    @dbCollection.find().sort({ points: orderBy }).toArray((err, results) =>
      user = results[0]
      userName = user._user
      userPoints = user.points

      if order is 'ascending'
        msg = "#{userName} is the leader with #{userPoints} points"
      else
        msg = "#{userName} is losing with #{userPoints} points"

      @bot.say(to, msg)
    )


  sayScore: (from, to, user) =>
    @dbCollection.findOne("_user":"#{user}", (error, userCallback) =>
      if (error)
        @_handleError(error)
      else
        if (!userCallback)
          # if the user doesnt exist we cant tell any scores
          msg = "#{user} has no points"
          @bot.say to, msg
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

  _checkLimit: (limitBy) =>
    ## We don't want to flood the chat with a bunch of scores
    if (limitBy >= 50 or limitBy is 0)
      return false
    else if isNaN(limitBy)
      return false
    else
      return true
    

  sayScores: (from, to, limit, order) =>
    console.log "SAYING SCORES #{limit} #{order}"
    if limit and order
      limitBy = parseInt(limit)

      console.log 'checking limit', @_checkLimit(limitBy)
      unless @_checkLimit(limitBy) then return false

      if order is 'ascending' then orderBy = -1 else orderBy = 1
      @dbCollection.find().limit(limitBy).sort({ points: orderBy }).toArray((err, results)  =>
        msg = for scores in results
          userScore = scores.points
          userName = scores._user
          "#{userName} has #{userScore} points"

        msg = msg.join(", ")
        @bot.say(to, msg)
      )
    else if limit
      limitBy = parseInt(limit)

      console.log 'checking limit', @_checkLimit(limitBy)
      unless @_checkLimit(limitBy) then return false

      @dbCollection.find().limit(limitBy).sort({$natural:-1}).toArray((err, results)  =>
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

  _handleBingbot: (user) =>
    if user is 'bingbot'
      user = 'b1ngbot'
    
    return user

  _initListeners: =>
    # Listen to new messages for addings and removing points 
    @bot.addListener 'message', (from, to, message) =>
      #console.log('%s => %s: %s', from, to, message)
      @clearScores()

      if match = message.match(/([+-]\d+)\s+(\S+)/)
        [_, score, user] = match
        score = parseInt(score)

        if @_handleBingbot(user) == from and score > 0
          score = -100

        @addScore(@_handleBingbot(user), score)

      else if match = message.match /^score (\S+)/

        user = match[1]
        
        @sayScore(from, to, @_handleBingbot(user))
      
      else if match = message.match /^whats the score (\S+) (\d+) (\S+)/

        if match[1] is '-l'
          limit = match[2]
          if match[3] is '-a' then order = 'ascending' else order = 'descending'
          @sayScores(from, to, limit, order)

      else if match = message.match /^whats the score (\S+) (\S+)/
        if match[1] is '-l'
          limit = match[2]
          @sayScores(from, to, limit)


      else if match = message.match /^whats the score (\S+)/
        if match[1] is '-a' then order = 'ascending' else order = 'descending'
        limit = 10
        @sayScores(from, to, limit, order)

      else if match = message.match /^whats the score/
        limit = 10
        @sayScores(from, to, limit)

        
      else if message.match /^points loser/
        order = 'descending'

        @findScores(from, to, order)

      else if message.match /^points leader/
        order = 'ascending'

        @findScores(from, to, order)

    # Something has gone wrong :(
    @bot.addListener 'error', (message) ->
      @_handleError(message)


  _connectDb: =>
    mongoQuery = "mongodb://#{@appID}:#{@appSecret}.mongolab.com:#{@databasePort}/#{@appID}"
    mongoUri = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || mongoQuery
    
    console.log "~~~!! CONNECTING TO DB !!~~~~ \n", mongoUri
    mongo.connect( mongoUri, @dbCollection, @_dbConnectCallback )


  _dbConnectCallback: (error, db) =>
    console.log '~~~!! CONNECTED TO MONGODB !!~~~~'

    ## if the db comes back as null || undefined we have a problem
    if (!db || error)
      if (!error) then error = "Database is undefined"
      return @_handleError(error)
      

    @database = db
    @dbModel = @database
    @database.addListener( "error", @_handleError )

    #creates collection of users
    @database.collection('users', (error, callback) =>
      if (error)
        @_handleError(error)
      else
        @dbCollection = @database.collection('users')
        @_connectBot()
    )
    

  _init: =>
    @_connectDb()

bot = new Scorpio(
  bot_name: 'scorpio',
  irc_channel: '#kanyeszone',
  app_name: 'heroku_app16378963',
  app_secret: 's8en8qk8u2jnhg31to2v7o4fq0@ds031608',
  app_port: '31608'
)
