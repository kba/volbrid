Backend = require '../backend'

XDOTOOL = 'xdotool'
WMCTRL = 'wmctrl'
module.exports = class Wmctrl extends Backend

	_commands: [WMCTRL]
	_modal: true

	get: (cb) ->
		@_exec WMCTRL, ['-d'], (err, data) =>
			return cb err if err
			return cb 'no data from wmctrl' unless data
			cur_workspace = parseInt data.toString().match(/(\d+)\s*\*/)[1]
			max_workspace = data.toString().match(/(\n)/g).length - 1
			@_exec WMCTRL, ['-l'], (err, data) =>
				windows_per_desktop = new Array(max_workspace)
				windows_per_desktop[k] or= {} for k of windows_per_desktop
				for line in data.split("\n")
					[wid, desktop_num, host] = line.split(/\s+/, 3)
					continue if typeof desktop_num is 'undefined'
					desktop_num = parseInt desktop_num
					continue if desktop_num < 0
					title = line.split(host)[1].trim()
					continue unless title
					windows_per_desktop[desktop_num] or= {}
					windows_per_desktop[desktop_num][title] = true
				# windows_per_desktop[k] = Object.keys(windows_per_desktop[k]) for k of windows_per_desktop
				windows_per_desktop[k] = Object.keys(windows_per_desktop[k]).length for k of windows_per_desktop
				console.log windows_per_desktop
				cb null, @_createGridMessage
					provider: 'workspace'
					value: cur_workspace
					max: max_workspace
					windows_per_desktop: windows_per_desktop

	_s: (arg, move, cb) ->
		@get (err, msg) =>
			return cb err if err
			new_workspace = msg.value + arg
			console.log new_workspace
			if new_workspace < 0
				new_workspace = msg.max + 1 + new_workspace
			else if new_workspace > msg.max
				new_workspace = new_workspace - msg.max - 1
			xdotool_cmds = []
			if move
				xdotool_cmds.push 'getactivewindow'
				xdotool_cmds.push 'set_desktop_for_window'
				xdotool_cmds.push '%1'
				xdotool_cmds.push new_workspace
			xdotool_cmds.push 'set_desktop'
			xdotool_cmds.push new_workspace
			console.log xdotool_cmds
			@_exec XDOTOOL, xdotool_cmds, cb

	inc:     (val, cb) -> @_s parseInt(val), false, cb
	dec:     (val, cb) -> @_s -1 * parseInt(val), false, cb
	up:      (val, cb) -> @_s -1 * @config.providers['workspace'].nr_cols, false, cb
	down:    (val, cb) -> @_s @config.providers['workspace'].nr_cols, false, cb
	move_next: (val, cb) -> @_s parseInt(val), true, cb
	move_prev: (val, cb) -> @_s -1 * parseInt(val), true, cb
	move_up:   (val, cb) -> @_s -1 * @config.providers['workspace'].nr_cols, true, cb
	move_down: (val, cb) -> @_s @config.providers['workspace'].nr_cols, true, cb
	set:     (val, cb) -> @_s val, cb
	toggle:  (cb) -> cb()
