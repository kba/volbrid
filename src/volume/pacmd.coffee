ChildProcess = require 'child_process'
Volume = require '../volume'
module.exports = class Pactl extends Volume

	get: (cb) ->
		pacmd = ChildProcess.spawn 'pacmd', ['list-sinks']
		pacmd.stdout.on 'data', (data) ->
			vol_line = data.toString().match /volume:.*\n/
			vol_left = vol_line[0].match(/(\d+)%/)[1]
			cb null, parseInt(vol_left)
		pacmd.on 'error', (err) ->
			console.log cb err

	inc: (perc, cb) ->
		self = @
		self.get (err, cur) ->
			throw err if err
			self.set (cur+perc), (err) ->
				cb err

	dec: (perc, cb) ->
		self = @
		self.get (err, cur) ->
			self.set (cur-perc), (err) ->
				cb err

	set: (perc, cb) ->
		pacmd = ChildProcess.spawn 'pactl', ['set-sink-volume', @config.pacmd.sink, '--', "#{perc}%"]
		pacmd.stdout.on 'data', (data) ->
			vol_line = data.toString().match /volume:.*\n/
			vol_left = vol_line[0].match(/(\d+)%/)[1]
		pacmd.on 'error', (err) ->
			console.log cb err
		pacmd.on 'exit', (err) ->
			cb null

  # CURVOL=$(pacmd list-sinks|grep -A 15 '* index'| awk '/volume: /{ print $3 }' | grep -m 1 % |sed 's/[%|,]//g') ||
    # CURVOL=$(pacmd list-sinks|grep -A 15 '* index'| awk '/volume: front/{ print $5 }' | sed 's/[%|,]//g')

