Backend = require '../backend'

ACPI = 'acpi'
module.exports = class Xbacklight extends Backend

	_commands: [ACPI]

	get: (cb) ->
		@_exec ACPI, ['--battery'], null, (data) ->
			level = data.toString().match(/(\d+)%/)[1]
			plugged_in = if data.toString().match(/Discharging/) then no else yes
			text = if plugged_in then null else data.toString().match(/([\d:]+) remaining/)[1]
			cb null, parseInt(level), plugged_in, text
