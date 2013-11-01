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
    @limit            = @options.search_limit

    #database configs
    @database         = null
    @dbCollection     = null
    @databasePort     = @options.app_port

    # init the new scorpio!
    @_init()

  clearScores: =>
    @dbCollection.remove( "total_score" : 0, (error, callback) =>
      if (error) then @_handleError(error)
    )


  addUser: (user, value, reason) =>
    #  if we have a reason we need to add the user into the db with the reason
    #  otherwise add the user with no reason. And an empty array
    if reason 
      console.log("adding user #{user} in the database. With a reason: #{reason}");
      @dbCollection.insert({"_user" : user, "total_score" : value, "reasons":  [{ "reason" : reason, "points" : value }] }, (error, inserted) =>
        if (error) then @_handleError(error)
      )
    else 
      console.log "Adding user #{user} in the database"
      @dbCollection.insert({"_user" : user, "total_score" : value, "reasons":  [] }, (error, inserted) =>
        if (error) then @_handleError(error)
      )   

  setUserScoreWithReason: (user, value, newScore, reason) =>
    console.log "SETTING NEW SCORE FOR #{user}, OLD SCORE: #{value}, NEW SCORE: #{newScore}"
    console.log "ADDING REASON #{reason} TO SCORE"

    ## Example Syntax:
    ## pushes new data into the _user field
    #db.users.update({"_user" : "omgomgomg"}, { $push: { "reasons" : { $each : [{"reason" : "you suck", "points" : 10 }] } } })
    #update( {"_user": { "$regex": "^omgomgomg$", "$options": "-i"}}, {$push: { "reasons" : { $each : [{"reason" : "you suck", "points" : 10 }] } } })

    @dbCollection.update( 
      {"_user": { "$regex": "^#{user}$","$options": "-i"}}, 
      {$push: { "reasons": { $each: [{"reason" : reason, "points" : value }] } } },
      {$set: {"total_score": newScore}}, (error, cb)  =>
        if (error) then @_handleError(error)
    )


  setUserScore: (user, currScore, newScore) =>
    console.log "SETTING NEW SCORE FOR #{user}, OLD SCORE: #{currScore}, NEW SCORE: #{newScore}"
    @dbCollection.update("_user": { "$regex": "^#{user}$", "$options": "-i" },{$set: {"total_score": newScore}}, (error, cb) =>
      if (error) then @_handleError(error)
    )

  findUserScore: (user, value, reason) =>
    console.log "user #{user} exists in the db"

    val = parseInt(value)
    currScore = null
    userReason = null
    newScore = null

    @dbCollection.findOne("_user":{ $regex: "^#{user}$", "$options": "-i" }, (error, userCallback) =>
      if (error)
        console.log "error"
        @_handleError(error)
      else
        #we need to get the value of user_field and update it
        console.log "WE FOUND USER #{user} DATA: #{val}"
        if (userCallback.total_score)
          currScore = userCallback.total_score
          newScore = (currScore += value)
          # check for if the user currently has reasons
          if (reason)
            console.log "USER HAS #{userCallback.reasons.length} REASONS FOR POINTS"
            @setUserScoreWithReason(user, val, newScore, reason)
          else
            @setUserScore(user, currScore, newScore)
    )

  addScore: (user, value, reason) =>
    userData = user
    console.log "ADDING SCORE FOR #{user}"

    unless user.indexOf("http://") is -1
      user = user.replace('http://', '')
      userData = user
      console.log user

    unless user.indexOf("https://") is -1
      user = user.replace('https://', '')
      userData = user
      console.log user

    # Get the Name of the user against the db
    @dbCollection.findOne( "_user": { $regex: "^#{userData}$", "$options": "-i"}, (error, userCallback) =>
      if userCallback is null
        # if user doesnt exist in the db add them
        @addUser(userData, value, reason)
      else
        # else if user exists in the db update their score with the new int
        @findUserScore(userData, value, reason)
    )

  findScores: (from, to, order) =>
    if order is 'ascending'
      orderBy = -1
    else
      orderBy = 1

    @dbCollection.find().sort({ points: orderBy }).limit(1).toArray((err, results) =>
      user = results[0]
      userName = user._user
      userPoints = user.total_score

      if order is 'ascending'
        msg = "#{userName} is the leader with #{userPoints} points"
      else
        msg = "#{userName} is losing with #{userPoints} points"

      @bot.say(to, msg)
    )

  sayScoreWithReasons: (from, to, user, limit) =>

    @dbCollection.findOne("_user": { $regex: "^#{user}$", "$options": "-i" }, (error, userCallback) =>
      if (error)
        @_handleError(error)
      else
        if (!userCallback)
          # if the user doesnt exist we cant tell any scores
          msg = "#{user} has no points"
          @bot.say to, msg
          return
        if (userCallback.total_score)
          # if the user has score we can print the score

          # find the reasons for the user if they exist, 
          # otherwise dont spit out any reasons
          if (userCallback.reasons.length)
            score = userCallback.total_score
            msg = "#{user} has #{score} points"
            @bot.say to, msg

            userReasons = userCallback.reasons
            if limit is "random" or isNaN(limit)

              if userCallback.reasons.length <= 1
                reason = userCallback.reasons[0]
                userReasons = "#{reason.points} points #{reason.reason}"
              else
                randInt = (Math.floor(Math.random() * (userCallback.reasons.length - 0 + 1)) + 0);
                reason = userCallback.reasons[randInt]
                userReasons = "#{reason.points} points #{reason.reason}"

            else
              reasonMessage = for item, i in userReasons
                ## do not pass our limit specified
                if i >= limit or i >= 10 then break
                "#{item.points} points #{item.reason}"

              userReasons = reasonMessage.join(", ")

            @bot.say to, userReasons
              
          else 
            score = userCallback.total_score
            msg = "#{user} has #{score} points"
            @bot.say to, msg
        else
          msg = "#{user} has no points"
          @bot.say to, msg
    )

    

  sayScore: (from, to, user) =>
    @dbCollection.findOne("_user": { $regex: "^#{user}$", "$options": "-i" }, (error, userCallback) =>
      if (error)
        @_handleError(error)
      else
        if (!userCallback)
          # if the user doesnt exist we cant tell any scores
          msg = "#{user} has no points"
          @bot.say to, msg
          return
        if (userCallback.total_score)
          # if the user has score we can print the score
          score = userCallback.total_score
          msg = "#{user} has #{score} points"
          @bot.say to, msg
        else
          msg = "#{user} has no points"
          @bot.say to, msg
    )

  _checkLimit: (limitBy) =>
    ## We don't want to flood the chat with a bunch of scores
    if (limitBy > @limit or limitBy is 0)
      return false
    else if isNaN(limitBy)
      return false
    else
      return true
    

  sayScoreCount: (from, to, limit, order) =>
    pointsTotal = null
    dbSize = null

    @dbCollection.stats((err, stats) =>
      pointsTotal = stats.count
      dbSize = stats.size
      console.log stats
      msg = "Total number of scores: #{pointsTotal}, database size: #{dbSize} Kb"
      @bot.say(to, msg)
    )

  sayAllTheScores : (from, to) =>
    scoreMessage = null
    process.maxTickDepth = 10000000000

    @dbCollection.find().sort({$natural:-1}).toArray((err, results)  =>
      scoreMessage = for scores, i in results
        userScore = scores.total_score
        userName = scores._user
        "#{userName} has #{userScore} points"

      scoreMessage = scoreMessage.join(", ")
      @bot.say(to, scoreMessage)
    )

    #msg = msg.join(", ")

    #@bot.say(to, msg)

  sayScores: (from, to, limit, order) =>
    console.log "SAYING SCORES #{limit} #{order}"
    if limit and order
      limitBy = parseInt(limit)

      console.log 'checking limit', @_checkLimit(limitBy)
      unless @_checkLimit(limitBy)
        msg = "You must enter an integer which cannot exceed #{@limit}"
        @bot.say(to, msg)
        return false

      if order is 'ascending' then orderBy = -1 else orderBy = 1
      @dbCollection.find().limit(limitBy).sort({ points: orderBy }).toArray((err, results)  =>
        msg = for scores in results
          userScore = scores.total_score
          userName = scores._user
          "#{userName} has #{userScore} points"

        msg = msg.join(", ")
        @bot.say(to, msg)
      )
    else if limit
      limitBy = parseInt(limit)

      console.log 'checking limit', @_checkLimit(limitBy)
      unless @_checkLimit(limitBy)
        msg = "You must enter an integer which cannot exceed #{@limit}"
        @bot.say(to, msg)
        return false

      @dbCollection.find().limit(limitBy).sort({$natural:-1}).toArray((err, results)  =>
        msg = for scores in results
          userScore = scores.total_score
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
      channels: @chatChannel,
      floodProtection: true,
      floodProtectionDelay: 500,
    )

    ## initialize the bot listeners
    @_initListeners()

  _handleBingbot: (user) =>
    if user.indexOf('bingbot') >= 0
      user = user.replace('bingbot','b1ngbot')

    return user

  _initListeners: =>
    # Listen to new messages for addings and removing points 
    @bot.addListener 'message', (from, to, message) =>
      #console.log('%s => %s: %s', from, to, message)
      @clearScores()

      if match = message.match(/([+-]\d+)\s+(\S+)\s+(for(.*))/)
        [_, score, user, reason] = match
        score = parseInt(score)
        reason_result = reason.replace(/[&\/\\#,+()$~%.'":*?<>{}]/g,'_')

        if @_handleBingbot(user) == from and score > 0
          score = -100

        ## handle mr_lucs failures as a #developer
        if @_handleBingbot(from) == 'derpo' then return false

        @addScore(@_handleBingbot(user), score, reason_result)

      else if match = message.match(/([+-]\d+)\s+(\S+)/)
        [_, score, user] = match
        score = parseInt(score)

        if @_handleBingbot(user) == from and score > 0
          score = -100

        ## handle mr_lucs failures as a #developer
        if @_handleBingbot(from) == 'derpo' then return false

        @addScore(@_handleBingbot(user), score)

      else if match = message.match /^score (\S+) -r (\d+)/
        console.log 'GIMME A LIST OF REASONS (up to 20)'

        user = match[1]
        limit = match[2]
        @sayScoreWithReasons(from, to, @_handleBingbot(user), limit)     
        
      else if match = message.match /^score (\S+) -r/
        console.log 'RANDOMIZE REASON'
        limit = 'random'
        user = match[1]

        @sayScoreWithReasons(from, to, @_handleBingbot(user), limit)     
        
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

      else if message.match(/^points (count|total)/)
        @sayScoreCount(from, to)

      else if message.match(/^help scorpio/)
        @sayAllTheScores(from, to)

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
  search_limit: 75,
  irc_channel: '#coolkidsusa'
  app_name: 'heroku_app16378963',
  app_secret: 's8en8qk8u2jnhg31to2v7o4fq0@ds031608',
  app_port: '31608'
)                     
