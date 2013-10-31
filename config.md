bot = new Scorpio(
  bot_name: 'scorpio',
  search_limit: 75,
  irc_channel: '#coolkidsusa'
  app_name: 'heroku_app16378963',
  app_secret: 's8en8qk8u2jnhg31to2v7o4fq0@ds031608',
  app_port: '31608'
)   

// To connect using the shell:


// Export JSON
mongoexport -h ds031608.mongolab.com:31608 -d heroku_app16378963 -c users -u heroku_app16378963 -p bf1215 -o users.json
