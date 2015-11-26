#!/usr/bin/env node
var options = {}
var Daemon = require('../lib/daemon');
var daemonize = require('daemon');
var Minimist = require('minimist');

var daemon = new Daemon(options);

var opts = Minimist(process.argv.slice(2));
if (typeof opts.nodaemon === 'undefined')
  opts.nodaemon = false

if (!opts.nodaemon)
  daemonize();

process.on('SIGINT', function() {
  console.log('Received SIGINT');
  daemon.stop();
  process.exit();
});

daemon.start();
