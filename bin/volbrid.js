#!/usr/bin/env node
// TODO parse options
var options = {}
var Daemon = require('../lib/daemon');
var daemonize = require('daemon');

var daemon = new Daemon(options);

process.on('SIGINT', function() {
  console.log('Received SIGINT');
  daemon.stop();
});

daemon.start();
