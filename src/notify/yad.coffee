Notify = require '../notify'
YAD = 'yad'
module.exports = class Yad extends Notify

	_commands: [YAD]

	notify: (backend, perc, disabled, text, cb) ->
		args = [
			"--on-top"
			"--no-buttons"
			"--center"
			"--splash"
			"--skip-taskbar"
			"--undecorated"
			"--sticky"
			"--image=#{@_icon(backend, perc, disabled)}"
			"--timeout=#{@_timeout_in_seconds()}"
		]
		unless disabled
			switch @config.notify.style
				when 'progress'
					args.push "--progress"
					args.push "--progress-text=#{backend} #{perc}%"
					args.push "--percentage=#{@_relative_percent(perc, backend)}"
				when 'ascii'
					args.push "--text=<big><tt>#{backend}: #{perc}%" +
						"\n#{@_ascii_bar @_relative_percent(perc, backend)}</tt></big>"
				when 'value'
					args.push "--text=<big><tt>#{backend}: #{perc}%</tt></big>"
		if text
			args.push "--text=#{text}"
		@_exec YAD, args, cb, null, true
