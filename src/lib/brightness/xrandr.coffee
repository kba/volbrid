Backend = require '../backend'
XRANDR = 'xrandr'
module.exports = class Xrandr extends Backend

	_commands: [XRANDR]
	_modal: true


	get: (cb) ->
		@_exec XRANDR, ['--verbose'], (err, str) =>
			@active_outputs = []
			cur = ''
			for line in str.split /\n/
				if m = line.match /^([A-Z0-8]+)/
					cur = m[1]
				if m = line.match /^\s+CRTC:\s*(\d)/
					@active_outputs.push cur
			brightness_str = str.match(/Brightness:\s*([01]\.[0-9]{1,2})/)[1]
			perc = 100 * parseFloat(brightness_str)
			cb null, @_createValueMessage
				provider: 'brightness'
				value: perc

	_xrandr_brightness: (perc,cb) ->
		args = []
		perc = Math.max(0, Math.min(100, perc))
		val = perc / 100.0
		if @config.providers.brightness.xrandr?.outputs
			outputs = @config.providers.brightness.xrandr?.outputs
		else
			outputs = @active_outputs
		for output in outputs
			args.push '--output'
			args.push output
			args.push '--brightness'
			args.push val
		@_exec XRANDR, args, cb, true

	dec: (delta, cb) -> @get (err, msg) => @_xrandr_brightness msg.value+(-1)*delta, cb
	inc: (delta, cb) -> @get (err, msg) => @_xrandr_brightness msg.value+(+1)*delta, cb
	set: (perc, cb) -> @_xrandr_brightness perc, cb
