config      = {
  user: 'scorpio'
  password: 'hotmilf69'
}
irc         = require 'irc'
nano        = require('nano')("http://#{config.user}:#{config.password}@scorpio.cujo.jp:5984/scorpio")
uuid        = require 'node-uuid'
pusher      = require 'pusher'


class Scorpio

  constructor : (options) ->
    @options          = options
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


  addUser: (user, value, reason) =>
    #  if we have a reason we need to add the user into the db with the reason
    #  otherwise add the user with no reason. And an empty array
    if reason
      console.log("adding user #{user} in the database. With a reason: #{reason}")

    else
      console.log "Adding user #{user} in the database"

  setUserScoreWithReason: (user, value, newScore, reason) =>
    console.log "SETTING NEW SCORE FOR #{user}, OLD SCORE: #{newScore-value}, NEW SCORE: #{newScore}"
    console.log "ADDING REASON #{reason} TO SCORE"

    ## Example Syntax:
    ## pushes new data into the _user field
    #db.users.update({"_user" : "omgomgomg"}, { $push: { "reasons" : { $each : [{"reason" : "you suck", "points" : 10 }] } } })
    #update( {"_user": { "$regex": "^omgomgomg$", "$options": "-i"}}, {$push: { "reasons" : { $each : [{"reason" : "you suck", "points" : 10 }] } } })

    #@pusher.trigger('scorpio_event', 'update', {
      #"message": "-- UPDATED SCORE W/REASON --"
      #"user": user
      #"points": value
      #"reason": reason
    #})


  setUserScore: (user, currScore, newScore, val) =>
    console.log "SETTING NEW SCORE FOR #{user}, OLD SCORE: #{currScore-val}, NEW SCORE: #{newScore}"

  findUserScore: (user, value, reason) =>
    console.log "user #{user} exists in the db"

    val = parseInt(value)
    currScore = null
    userReason = null
    newScore = null

  addScore: (user, from, value, reason) =>
    userData = user
    id = uuid.v1()
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
    nano.insert({
      awardedBy: from || null
      points: value
      subject: user
      reason: reason || []
    }, id, (err, body, header) =>
      if (err)
        console.log('[nano.insert] ', err.message)
        return
    )

  checkCallback: (cb) =>
    if typeof cb is "function"
      return true
    else
      return false

  findScores: (from, to, order, cb) =>
    if order is 'ascending'
      orderBy = -1
    else
      orderBy = 1

    nano.view('scorpio', "get-score-by-key?group=true", (err, body) =>
      pointsArray = []

    )

  getRandomItemFromArray: (arr, num) =>
    result = new Array(num)
    len = arr.length
    taken = new Array(len)

    console.log 'a', num, len
    if (num > len)
      num = len
      result = new Array(num)
      len = arr.length
      taken = new Array(len)
      
    while (num--)
      x = Math.floor(Math.random() * len)
      result[num] = arr[(if x of taken then taken[x] else x)]
      taken[x] = --len

    return result

  getScore: (user, reasonLimit, cb) =>
    msg = ""

    nano.view('scorpio', "get-score-by-key?group=true", {keys: [user]},(err, body) =>
      if (!err)
        if (body.rows && body.rows.length > 0)
          body.rows.forEach( (doc) =>
            points = doc.value.points
            msg = "#{user} has #{points} points"

            reasonArray = []
            reasonObject = {}

            ## if we have a reason we should get the reasons form the body.
            if reasonLimit && doc.value.reasons.length
              
              ## lets get all the reasons in a decent variable
              subjectReasons = doc.value.reasons

              ## need to get a random reason if its random
              if reasonLimit is "random"
                subjectReasonItem = subjectReasons[@_randomInt(0, subjectReasons.length)]

                ## build the reasonObject so we can parse it into a string
                reasonObject.awardedBy = subjectReasonItem.awardedBy || null
                reasonObject.points = subjectReasonItem.points || 0
                reasonObject.comment = subjectReasonItem.reason || null
                reasonObject.verb = if (reasonObject.points >= 0) then "awarded" else "negated"

                reasonString = "Was #{reasonObject.verb} #{reasonObject.points} from #{reasonObject.awardedBy} #{reasonObject.comment}"

                ## Redefine the message
                msg = "#{user} has #{points} points. \n #{reasonString}"

              else
                for subjectReasonItem, i in subjectReasons
                  ## build the reasonObject so we can parse it into a string
                  reasonObject.awardedBy = subjectReasonItem.awardedBy || null
                  reasonObject.points = subjectReasonItem.points || 0
                  reasonObject.comment = subjectReasonItem.reason || null
                  reasonString = "#{reasonObject.points} point from #{reasonObject.awardedBy} #{reasonObject.comment}"
                  
                  reasonArray.push(reasonString)

                finalReasonArray = @getRandomItemFromArray(reasonArray, reasonLimit)

                msg = "#{user} has #{points} points. \n #{finalReasonArray.join(', ')}"

            if @checkCallback(cb)
              cb(msg)
          )
        else
          msg = "No points found for #{user}"
          cb(msg)
    )


  sayScoreWithReasons: (from, to, user, limit) =>
    @getScore(user, limit, (msg) =>
      console.log msg
      @bot.say(to, msg)
    )


  sayScore: (from, to, user) =>
    @getScore(user, null, (msg) =>
      console.log msg
      @bot.say(to, msg)
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


  sayAllTheScores : (from, to) =>
    scoreMessage = null
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

    else if limit
      limitBy = parseInt(limit)

      console.log 'checking limit', @_checkLimit(limitBy)
      unless @_checkLimit(limitBy)
        msg = "You must enter an integer which cannot exceed #{@limit}"
        @bot.say(to, msg)
        return false

  _handleError: (message) =>
    # quality error handling 
    # +1 darkcypher_bit (aka. ratfuk, encrypted_fractal, COMPUTER_HOBBY)
    throw new Error "fuk #{message}"

  _connectBot: =>
    @bot = new irc.Client('irc.freenode.net', "#{@botName}",
      debug: true,
      channels: @chatChannel,
      certExpired: true,
      secure: true,
      port: 7070,
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

      if match = message.match(/([+-]\d+)\s+(\S+)\s+(for(.*))/)
        [_, score, user, reason] = match
        score = parseInt(score)
        reason_result = reason.replace(/[&\/\\#+'"<>]/g,'_')

        if @_handleBingbot(user) == from and score > 0
          score = -100

        ## handle mr_lucs failures as a #developer
        if @_handleBingbot(from) == 'derpo' then return false

        @addScore(@_handleBingbot(user), from, score, reason_result)

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


  _initPusher: =>
    @pusher = new pusher({
      appId: '62686',
      key: '3ea910de3b4179ff0d0e',
      secret: 'a946198efebd0b12a81d'
    })

  _connectDb: =>
    #nano.auth(u, pw, (err, body, headers) =>
      #if (err)
        #console.log u, pw, err, body, headers
        #@_handleError(err)

      #if (headers and headers['set-cookie'])
        #cookie[user] = headers['set-cookie']

      #@_connectBot()
    #)
    @_connectBot()
    

  _init: =>
    @_connectDb()
    @_initPusher()

  _randomInt: (low,high) =>
    return low + Math.floor(Math.random() * (high - low))
    
    

bot = new Scorpio(
  bot_name: 'scorpio',
  search_limit: 75,
  irc_channel: '#coolkidsusa'
  app_name: 'heroku_app16378963',
  app_secret: 's8en8qk8u2jnhg31to2v7o4fq0@ds031608',
  app_port: '31608'
)
