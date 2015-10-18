Backend = require '../backend'

AMIXER = 'amixer'
module.exports = class Amixer extends Backend

	_commands: [AMIXER]

	get: (cb) ->
		@_exec AMIXER, ['sget', @config.providers.volume.amixer.control], (err, data) ->
			vol_left = data.toString().match(/(\d+)%/)[1]
			muted_line = data.toString().match /\[off\]/
			muted = if muted_line then yes else no
			cb null, parseInt(vol_left), muted

	_sset: (arg, cb) ->
		args = ['sset', @config.providers.volume.amixer.control, arg]
		@_exec AMIXER, args, cb

	inc: (perc, cb) -> @_sset "#{perc}%+", cb
	dec: (perc, cb) -> @_sset "#{perc}%-", cb
	set: (perc, cb) -> @_sset "#{perc}%", cb
	toggle: (cb) -> @_sset "toggle", cb
