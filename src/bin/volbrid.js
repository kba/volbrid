#!/usr/bin/env node
var options = {}
var Daemon = require('../lib/daemon');
var daemonize = require('daemon');

var daemon = new Daemon(options);

// TODO parse options
var opts = {'nodaemon':1}
if (!opts.nodaemon)
  daemonize();

process.on('SIGINT', function() {
  console.log('Received SIGINT');
  daemon.stop();
  process.exit();
});

daemon.start();
