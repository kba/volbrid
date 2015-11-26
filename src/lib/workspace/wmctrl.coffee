Backend = require '../backend'

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
					desktop_num = parseInt desktop_num
					continue unless desktop_num
					continue if desktop_num is -1
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

	_s: (arg, cb) ->
		@get (err, msg) =>
			return cb err if err
			new_workspace = msg.value + arg
			console.log new_workspace
			if new_workspace < 0
				new_workspace = msg.max + 1 + new_workspace
			else if new_workspace > msg.max
				new_workspace = new_workspace + 1 - msg.max
			args = ['-s', new_workspace]
			@_exec WMCTRL, args, cb

	inc: (perc, cb)  -> @_s parseInt(perc), cb
	dec: (perc, cb)  -> @_s -1 * parseInt(perc), cb
	up: (perc, cb) -> @_s -1 * @config.providers['workspace'].nr_cols, cb
	down: (perc, cb)   -> @_s @config.providers['workspace'].nr_cols, cb
	set: (perc, cb)  -> @_s perc, cb
	toggle: (cb) -> cb()
