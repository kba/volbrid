Backend = require '../backend'

XBACKLIGHT = 'xbacklight'
module.exports = class Xbacklight extends Backend

	_commands: [XBACKLIGHT]

	get: (cb) ->
		@_exec XBACKLIGHT, ['-get'], (err, data) =>
			cb null, @_createValueMessage
				provider: 'brightness'
				value: parseInt(data)

	inc: (perc, cb) -> @_exec XBACKLIGHT, ['-time', 0, '-inc', "#{perc}"], cb
	dec: (perc, cb) -> @_exec XBACKLIGHT, ['-time', 0, '-dec', "#{perc}"], cb
	set: (perc, cb) -> @_exec XBACKLIGHT, ['-time', 0, '-set', "#{perc}"], cb
