Backend = require '../backend'

ACPI = 'acpi'
module.exports = class Acpi extends Backend

	_commands: [ACPI]

	get: (cb) ->
		@_exec ACPI, ['--battery'], (err, data) =>
			console.log err if err
			level = data.toString().match(/(\d+)%/)[1]
			plugged_in = if data.toString().match(/Discharging/) then no else yes
			text = if plugged_in then null else data.toString().match(/([\d:]+) remaining/)[1]
			cb null, @_createValueMessage
				provider: 'battery'
				value: parseInt(level)
				disabled: plugged_in
				text: text
