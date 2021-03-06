{ValueMessage} = require '../message'
Backend = require '../backend'

PACTL = 'pactl'
PACMD = 'pacmd'
module.exports = class PulseAudio extends Backend

	_commands: [PACTL, PACMD]
	_pgrep: ['pulseaudio']

	get: (cb) ->
		@_exec PACMD, ['list-sinks'], (err, data) =>
			if not data
				console.log 'ERROR: pacmd list-sinks gave no resposne'
				return cb 100, false
			vol_line = data.toString().match /volume:.*\n/
			vol_left = vol_line[0].match(/(\d+)%/)[1]
			muted_line = data.toString().match /muted:.*\n/
			muted = if muted_line[0].match(/yes/) then yes else no
			cb null, @_createValueMessage
				provider: 'volume'
				value: parseInt(vol_left)
				disabled: muted

	_set_sink_volume: (prefix, perc, cb) ->
		args = ['set-sink-volume', @config.providers.volume.pulseaudio.sink, "--", "#{prefix}#{perc}%"]
		@_exec PACTL, args, cb

	inc: (perc, cb) -> @_set_sink_volume '+', perc, cb
	dec: (perc, cb) -> @_set_sink_volume '-', perc, cb
	set: (perc, cb) -> @_set_sink_volume '', perc, cb

	toggle: (cb) ->
		args = ['set-sink-mute', @config.providers.volume.pulseaudio.sink, 'toggle']
		@_exec PACTL, args, cb
