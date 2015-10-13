ChildProcess = require 'child_process'
Backend = require '../backend'

PACTL = 'pactl'
PACMD = 'pacmd'
module.exports = class PulseAudio extends Backend

	_commands: [PACTL, PACMD]

	get: (cb) ->
		@_exec PACMD, ['list-sinks'], null, (data) ->
			vol_line = data.toString().match /volume:.*\n/
			vol_left = vol_line[0].match(/(\d+)%/)[1]
			muted_line = data.toString().match /muted:.*\n/
			muted = if muted_line[0].match(/yes/) then yes else no
			cb null, parseInt(vol_left), muted

	inc: (perc, cb) ->
		args = ['set-sink-volume', @config.providers.volume.pulseaudio.sink, "+#{perc}%"]
		@_exec PACTL, args, cb

	dec: (perc, cb) ->
		args = ['set-sink-volume', @config.providers.volume.pulseaudio.sink, "--", "-#{perc}%"]
		@_exec PACTL, args, cb

	set: (perc, cb) ->
		args = ['set-sink-volume', @config.providers.volume.pulseaudio.sink, "#{perc}%"]
		@_exec PACTL, args, cb

	toggle: (cb) ->
		args = ['set-sink-mute', @config.providers.volume.pulseaudio.sink, 'toggle']
		@_exec PACTL, args, cb
