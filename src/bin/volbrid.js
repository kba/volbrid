#!/usr/bin/env node
var Daemon = require('../lib/daemon');
var daemonize = require('daemon');
var Minimist = require('minimist');

var opts = Minimist(process.argv.slice(2));
if (typeof opts.nodaemon === 'undefined')
  opts.nodaemon = false

if (!opts.nodaemon)
  daemonize();

var daemon = new Daemon(opts);

process.on('SIGINT', function() {
  console.log('Received SIGINT');
  daemon.stop();
  process.exit();
});

daemon.start();
