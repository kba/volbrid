Notify = require '../notify'
module.exports = class Yad extends Notify

	notify_volume: (perc, muted, cb) ->
		args = [
			"--on-top"
			"--no-buttons"
			"--center"
			"--skip-taskbar"
			"--undecorated"
			"--sticky"
			"--image=#{@_icon_for_volume(perc, muted)}"
			"--timeout=#{Math.ceil(@config.notify.timeout / 1000)}"
		]
		unless muted
			switch @config.notify.style
				when 'progress'
					args.push "--progress"
					args.push "--progress-text=Volume #{perc}%"
					args.push "--percentage=#{perc}"
				when 'ascii'
					args.push "--text=<big><tt>VOLUME: #{perc}%\n#{@_create_ascii_bar(perc)}</tt></big>"
				when 'value'
					args.push "--text=<big><tt>VOLUME: #{perc}%</tt></big>"
		@_exec 'yad', args, cb

	notify_brightness: (perc, muted, cb) ->
		args = [
			"--on-top"
			"--no-buttons"
			"--center"
			"--skip-taskbar"
			"--undecorated"
			"--sticky"
			"--image=#{@config.icons.brightness}"
			"--timeout=#{Math.ceil(@config.notify.timeout / 1000)}"
		]
		switch @config.notify.style
			when 'progress'
				args.push "--progress"
				args.push "--percentage=#{perc}"
			when 'ascii'
				args.push "--text=<big><tt>BRIGHTNESS: #{parseInt(perc)}%\n#{@_create_ascii_bar(perc)}</tt></big>"
			when 'value'
				args.push "--text=<big><tt>BRIGHTNESS: #{perc}%</tt></big>"
		@_exec 'yad', args, cb
