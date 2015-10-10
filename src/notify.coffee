CmdExecutor = require './cmd_executor'
module.exports = class Notify extends CmdExecutor

	constructor: (@config) ->

	_icon_for_volume: (perc, muted) ->
		if muted
			return @config.icons.mute
		else if perc <= 33
			return @config.icons.volume_low
		else if perc <= 66
			return @config.icons.volume_medium
		else
			return @config.icons.volume_high

	volume : (perc, muted, cb) ->
		throw "Not implemented"

	brightness : (perc, cb) ->
		throw "Not implemented"

