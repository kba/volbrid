CSON = require 'cson'
CONFIG = CSON.load './config.cson'
console.log process.argv
# console.log CONFIG

volume_class_name = CONFIG.volume
volume_class = require "./src/volume/#{volume_class_name}"
notify_class_name = CONFIG.notify
notify_class = require "./src/notify/#{notify_class_name}"

volume = new volume_class(CONFIG)
notify = new notify_class(CONFIG)

api =
	volume_get: ->
		volume.get (err, perc) ->
			notify.notifyVolume perc, (err) ->
				console.log 'done'
	volume_inc: ->
		volume.inc CONFIG.volume_step, @volume_get
	volume_mute: ->
		volume.set 0, @volume_get
	volume_dec: ->
		volume.dec CONFIG.volume_step, @volume_get

api[process.argv[2]]()

# volume.inc 10, (err) ->
