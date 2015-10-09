Fs = require 'fs'
DeepMerge = require './deepmerge'
CONFIG =
	volume:
		backend: "pacmd"
		step: 10
		max: 250
	brightness:
		backend: "xbacklight"
		step: 10
	notify:
		backend: "notify_send"  # notify_send, yad
		timeout: 50  # in ms
		style: 'ascii'  # ascii, progress, value
		fillchar: '0'
	icons:
		mute: "audio-volume-muted"
		volume_low: "audio-volume-low"
		volume_medium: "audio-volume-medium"
		volume_high: "audio-volume-high"
		brightness: "display-brightness-symbolic"
	pacmd:
		sink: 0
for path in [
	"/etc/volbriosd/config.json",
	"#{process.env.HOME}/.config/volbriosd/config.json"
	"#{process.cwd()}/volbriosd.json"
	]
	if Fs.existsSync path
		localConfig = JSON.parse(Fs.readFileSync(path))
		CONFIG = DeepMerge(CONFIG, localConfig)

backends = {}
for backend_type in ['volume', 'brightness', 'notify']
	backend_class = require "../lib/#{backend_type}/#{CONFIG[backend_type].backend}"
	backends[backend_type] = new backend_class(CONFIG)

api =
	brightness:
		get: ->
			backends.brightness.get (err, perc) ->
				backends.notify.notify_brightness perc
		up: ->
			backends.brightness.inc CONFIG.brightness.step, @get
		down: ->
			backends.brightness.dec CONFIG.brightness.step, @get
	volume:
		get: ->
			backends.volume.get (err, perc, muted) ->
				backends.notify.notify_volume perc, muted
		up: ->
			backends.volume.inc CONFIG.volume.step, @get
		down: ->
			backends.volume.dec CONFIG.volume.step, @get
		toggle_mute: ->
			backends.volume.toggle_mute @get

backend = process.argv[2]
cmd = process.argv[3]

api[backend][cmd]()

# volume.inc 10, (err) ->
