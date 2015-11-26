Which = require 'which'
ChildProcess = require 'child_process'
module.exports = class CmdExecutor

	# Pattern to grep for in processes. Throw an error if any of the processes
	# isn't found. Useful for provider backends that require a daemon running
	# (e.g. pulseaudio)
	_pgrep: []

	_modal: false

	constructor: (@config) ->
		for pat in @_pgrep
			ret = ChildProcess.execSync "pgrep '#{pat}'"
		for cmd in @_commands
			Which.sync cmd

	_exec: (cmd_name, args, cb) ->
		if @config.debug >= 1
			console.log "$ #{cmd_name + ' ' + args.join(' ')}"
		cmd = ChildProcess.spawn cmd_name, args
		str_stdout = ''
		cmd.stdout.on 'data', (data) ->
			str_stdout += data.toString()
		if @config.debug >= 3
			cmd.stdout.on 'data', (data) -> console.log "[STDOUT] '#{cmd_name} [#{args}]': #{data}"
			cmd.stderr.on 'data', (data) -> console.log "[STDERR] '#{cmd_name} [#{args}]: #{data}"
		else if @config.debug >= 2
			cmd.stdout.on 'data', (data) -> console.log "[STDOUT]: #{data}"
			cmd.stderr.on 'data', (data) -> console.log "[STDERR]: #{data}"
		cmd.on 'error', (err) ->
			if cb
				cb "_exec Error: #{err}"
		cmd.on 'exit', (err) ->
			if cb
				cb err, str_stdout

# ALT: ../lib/cmd_executor.js
