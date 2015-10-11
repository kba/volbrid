Notify = require '../notify'
module.exports = class VolnotiShow extends Notify

	volume: (perc, muted, cb) ->
		args = [
			"#{perc}"
		]
		if muted
			args.push "-m"
		@_exec 'volnoti-show', args, cb
