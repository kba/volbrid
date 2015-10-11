Notify = require '../notify'
module.exports = class VolnotiShow extends Notify

	volume: (perc, muted, cb) ->
		args = [
			"#{perc / @config.volume.max * 100}"
		]
		if muted
			args.push "-m"
		@_exec 'volnoti-show', args, cb

	brightness: (perc, cb) ->
		args = [
			"-T",  "brightness"
			"#{perc / @config.brightness.max * 100}"
		]
		@_exec 'volnoti-show', args, cb
