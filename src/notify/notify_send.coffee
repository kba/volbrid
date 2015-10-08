Notify = require '../notify'
module.exports = class NotifySend extends Notify

	notify_volume: (perc, muted, cb) ->
		args = [
			"--icon=#{@_icon_for_volume(perc, muted)}"
			"--expire-time=#{@config.notify.timeout}"
		]
		if muted
			args.push " "
		else
			switch @config.notify.style
				when 'ascii'
					args.push "VOLUME: #{perc}%"
					args.push "<big><tt>#{@_create_ascii_bar(perc)}%</tt></big>"
				when 'value'
					args.push "--text=<big><tt>VOLUME: #{perc}%</tt></big>"
				when 'progress'
					args.push "--hint=int:value:#{perc}"
					args.push "--hint=string:synchronous:volume"
		@_exec 'notify-send', args, cb


	notify_brightness: (perc, muted, cb) ->
		args = [
			"--icon=#{@config.icons.brightness}"
			"--expire-time=#{@config.notify.timeout}"
		]
		switch @config.notify.style
			when 'ascii'
				args.push "BRIGHTNESS: #{perc}%"
				args.push "<tt>#{@_create_ascii_bar(perc)}%</tt>"
			when 'value'
				args.push "--text=<big><tt>BRIGHTNESS: #{perc}%</tt></big>"
			when 'progress'
				args.push "--hint=int:value:#{perc}"
				args.push "--hint=string:synchronous:brightness"
		@_exec 'notify-send', args, cb

