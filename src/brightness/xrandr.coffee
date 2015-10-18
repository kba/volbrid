Backend = require '../backend'
XRANDR = 'xrandr'
module.exports = class Xrandr extends Backend

	_commands: [XRANDR]
	_modal: true

	get: (cb) ->
		@_exec XRANDR, ['--verbose'], (err, str) ->
			brightness_str = str.match(/Brightness:\s*([01]\.[0-9]{1,2})/)[1]
			console.log "EXTRACTED: #{brightness_str}"
			perc = 100 * parseFloat(brightness_str)
			console.log "PARSED: #{perc}"
			cb null, perc

	_xrandr_brightness: (perc, cb) ->
		args = []
		console.log perc
		perc = Math.max(0, Math.min(100, perc))
		val = perc / 100.0
		for output in @config.providers.brightness.xrandr.outputs
			args.push '--output'
			args.push output
			args.push '--brightness'
			args.push val
		@_exec XRANDR, args, cb, true

	dec: (delta, cb) -> @get (err, perc) => @_xrandr_brightness perc+(-1)*delta, cb
	inc: (delta, cb) -> @get (err, perc) => @_xrandr_brightness perc+(+1)*delta, cb
	set: (perc, cb) -> @_xrandr_brightness perc, cb
