module.exports = class Notify

	constructor: (@config) ->

	_icon_for_volume: (perc) ->
		if perc <= 0
			return @config.icons.mute
		else if perc <= 33
			return @config.icons.volume_low
		else if perc <= 66
			return @config.icons.volume_medium
		else
			return @config.icons.volume_high


	notifyVolume : (perc, cb) ->
		throw "Not implemented"

	notifyBrightness : (perc, cb) ->
		throw "Not implemented"

