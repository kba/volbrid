Which = require 'which'
ChildProcess = require 'child_process'
module.exports = class CmdExecutor

	constructor: (@config) ->
		for cmd in @_commands
			Which.sync cmd

	_exec: (cmd_name, args, cb, data_cb, pkill) ->
		self = @
		cmd_cb = (err) ->
			if self.config.debug >= 1
				console.log "$ #{cmd_name + ' ' + args.join(' ')}"
			cmd = ChildProcess.spawn cmd_name, args
			if data_cb
				cmd.stdout.on 'data', data_cb
			if self.config.debug >= 3
				cmd.stdout.on 'data', (data) -> console.log "[STDOUT] '#{cmd_name} [#{args}]': #{data}"
				cmd.stderr.on 'data', (data) -> console.log "[STDERR] '#{cmd_name} [#{args}]: #{data}"
			else if self.config.debug >= 2
				cmd.stdout.on 'data', (data) -> console.log "[STDOUT]: #{data}"
				cmd.stderr.on 'data', (data) -> console.log "[STDERR]: #{data}"
			if cb
				cmd.on 'exit', (err) ->
					if err then cb err else cb null
		if pkill
			kill = ChildProcess.spawn 'pkill', [cmd_name]
			kill.on 'exit', cmd_cb
		else
			cmd_cb()
