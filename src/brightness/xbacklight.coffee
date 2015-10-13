Backend = require '../backend'

XBACKLIGHT = 'xbacklight'
module.exports = class Xbacklight extends Backend

	_commands: [XBACKLIGHT]

	get: (cb) ->
		@_exec XBACKLIGHT, ['-get'], null, (data) ->
			cb null, parseInt(data)
	inc: (perc, cb) -> @_exec XBACKLIGHT, ['-inc', "#{perc}"], cb
	dec: (perc, cb) -> @_exec XBACKLIGHT, ['-dec', "#{perc}"], cb
	set: (perc, cb) -> @_exec XBACKLIGHT, ['-set', "#{perc}"], cb
