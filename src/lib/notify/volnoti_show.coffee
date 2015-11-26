Notify = require '../notify'

CMD = 'volnoti-show'
module.exports = class VolnotiShow extends Notify

	_commands: [CMD]

	notify: (msg, cb) ->
		args = [
			"-T", msg.provider
			msg.format 'relative-percent'
		]
		if msg.disabled
			args.push "-m"
		@_exec CMD, args, cb
