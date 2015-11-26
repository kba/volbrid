Backend = require '../backend'

WMCTRL = 'wmctrl'
module.exports = class Amixer extends Backend

	_commands: [WMCTRL]

	get: (cb) ->
		@_exec WMCTRL, ['-d'], (err, data) ->
			cur_workspace = data.toString().match(/(\d+)\s*\*/)[1]
			max_workspace = data.toString().match(/(\n)/g).length - 1
			cb null, parseInt(cur_workspace), false, null, max_workspace

	_s: (arg, cb) ->
		@get (err, cur_workspace, _muted, _text, max_workspace) =>
			new_workspace = cur_workspace + arg
			new_workspace = 0 if new_workspace > max_workspace
			new_workspace = max_workspace if new_workspace < 0
			args = ['-s', new_workspace]
			@_exec WMCTRL, args, cb

	inc: (perc, cb) -> @_s +1, cb
	dec: (perc, cb) -> @_s -1, cb
	set: (perc, cb) -> @_s perc, cb
	toggle: (cb) -> cb()
