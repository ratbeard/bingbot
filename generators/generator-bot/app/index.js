'use strict';
var util = require('util');
var path = require('path');
var yeoman = require('yeoman-generator');


var botname = null
var BotGenerator = module.exports = function BotGenerator(args, options, config) {
	botname = args[0]
  yeoman.generators.Base.apply(this, arguments);
};

util.inherits(BotGenerator, yeoman.generators.Base);

BotGenerator.prototype.askFor = function askFor() {
  var cb = this.async();

  var prompts = [{
    name: 'bot',
    message: 'Bot name?',
    default: 'newbot'
  }];
	if (botname) prompts.shift()

  this.prompt(prompts, function (props) {
    this.bot = botname || props.bot;
		this.botClass = this.bot[0].toUpperCase() + this.bot.slice(1);
    cb();
  }.bind(this));
};

BotGenerator.prototype.app = function app() {
	path = 'src/bots/' + this.bot + '/'
  this.mkdir(path);
	this.template("api.coffee", path + 'api.coffee')
	this.template("bot.coffee", path + 'bot.coffee')
};

BotGenerator.prototype.projectfiles = function projectfiles() {
  //this.copy('editorconfig', '.editorconfig');
  //this.copy('jshintrc', '.jshintrc');
};

