ChildProcess = require 'child_process'
module.exports = class CmdExecutor

	_create_ascii_bar: (perc, max, muted) ->
		barmax = max / 5
		fillmax = Math.ceil(perc / 5)
		bar = ''
		for i in [0 ... fillmax]
			bar += @config.notify.fillchar
		if fillmax < barmax
			bar += '>'
		if fillmax < barmax - 1
			for i in [fillmax + 1 ... barmax]
				bar += '-'
		return "[#{bar}]"

	_exec: (cmd_name, args, cb) ->
		kill = ChildProcess.spawn 'pkill', [cmd_name]
		kill.on 'exit', (err) =>
			console.log "Execute #{cmd_name + ' ' + args.join(' ')}"
			cmd = ChildProcess.spawn cmd_name, args
			if @config.debug
				cmd.stdout.on 'data', (data) -> console.log "#{cmd_name} [#{args}] STDOUT: #{data}"
				cmd.stderr.on 'data', (data) -> console.log "#{cmd_name} [#{args}] STDERR: #{data}"
			cmd.on 'exit', (err) ->
				cb null if cb
