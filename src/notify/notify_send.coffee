Notify = require '../notify'
module.exports = class NotifySend extends Notify

	volume: (perc, muted, cb) ->
		args = [
			"--icon=#{@_icon_for_volume(perc, muted)}"
			"--expire-time=#{@config.notify.timeout}"
			"--hint=string:synchronous:volume"
		]
		switch @config.notify.style
			when 'ascii'
				args.push "VOLUME: #{perc}"
				args.push "<big><tt>#{@_create_ascii_bar(perc, @config.volume.max)}</tt></big>"
			when 'value'
				args.push "VOLUME #{perc}"
			when 'progress'
				args.push "--hint=int:value:#{perc * 100 / @config.volume.max}"
				args.push "--hint=string:synchronous:volume"
				args.push "VOLUME #{perc}"
		@_exec 'notify-send', args, cb


	brightness: (perc, muted, cb) ->
		args = [
			"--icon=#{@config.icons.brightness}"
			"--expire-time=#{@config.notify.timeout}"
		]
		switch @config.notify.style
			when 'ascii'
				args.push "BRIGHTNESS: #{perc}"
				args.push "<tt>#{@_create_ascii_bar(perc, @config.brightness.max)}</tt>"
			when 'value'
				args.push "<big><tt>BRIGHTNESS: #{perc}</tt></big>"
			when 'progress'
				args.push "--hint=int:value:#{perc}"
				args.push "--hint=string:synchronous:brightness"
				args.push " "
		@_exec 'notify-send', args, cb

