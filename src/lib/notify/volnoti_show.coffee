Notify = require '../notify'

CMD = 'volnoti-show'
module.exports = class VolnotiShow extends Notify

	_commands: [CMD]

	notify: (backend, perc, disabled, text, cb) ->
		args = [
			"-T", backend
			@_relative_percent(perc, backend)
		]
		if disabled
			args.push "-m"
		@_exec CMD, args, cb
