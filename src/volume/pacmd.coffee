ChildProcess = require 'child_process'
Volume = require '../volume'
module.exports = class Pacmd extends Volume

	get: (cb) ->
		args = ['list-sinks']
		cmd = ChildProcess.spawn 'pacmd', args
		cmd.stdout.on 'data', (data) ->
			vol_line = data.toString().match /volume:.*\n/
			muted_line = data.toString().match /muted:.*\n/
			vol_left = vol_line[0].match(/(\d+)%/)[1]
			muted = if muted_line[0].match(/yes/) then yes else no
			cb null, parseInt(vol_left), muted
		if @config.debug
			cmd.stdout.on 'data', (data) -> console.log "[pacmd #{args}]\nSTDOUT: #{data}"
			cmd.stderr.on 'data', (data) -> console.log "[pacmd #{args}]\nSTDERR: #{data}"
		cmd.on 'error', (err) ->
			console.log cb err

	inc: (perc, cb) ->
		@get (err, cur, muted) =>
			@set (cur + perc), cb

	dec: (perc, cb) ->
		@get (err, cur, muted) =>
			@set (cur - perc), cb

	set: (perc, cb) ->
		args = ['set-sink-volume', @config.pacmd.sink, '--', "#{perc}%"]
		cmd = ChildProcess.spawn 'pactl', args
		cmd.stdout.on 'data', (data) ->
			vol_line = data.toString().match /volume:.*\n/
			vol_left = vol_line[0].match(/(\d+)%/)[1]
		if @config.debug
			cmd.stdout.on 'data', (data) -> console.log "[pactl #{args}]\nSTDOUT: #{data}"
			cmd.stderr.on 'data', (data) -> console.log "[pactl #{args}]\nSTDERR: #{data}"
		cmd.on 'exit', cb

	toggle_mute: (cb) ->
		@_exec 'pactl', ['set-sink-mute', @config.pacmd.sink, 'toggle']
