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
		max: 100
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

backend = process.argv[2]
cmd = process.argv[3]
val = if process.argv[4] then process.argv[4] else CONFIG[backend].step

backend_get = ->
	backends[backend].get (err, perc) ->
		backends.notify[backend] perc
switch cmd
	when 'get'
		backend_get()
	when 'inc', 'dec', 'set'
		backends[backend][cmd] val, backend_get
	else
		backends[backend][cmd] backend_get

# volume.inc 10, (err) ->
