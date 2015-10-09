ChildProcess = require 'child_process'
module.exports = class Notify

	constructor: (@config) ->

	_icon_for_volume: (perc, muted) ->
		if muted
			return @config.icons.mute
		else if perc <= 33
			return @config.icons.volume_low
		else if perc <= 66
			return @config.icons.volume_medium
		else
			return @config.icons.volume_high

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

	notify_volume : (perc, muted, cb) ->
		throw "Not implemented"

	notify_brightness : (perc, cb) ->
		throw "Not implemented"

