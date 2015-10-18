Notify = require '../notify'
module.exports = class NotifySend extends Notify

	_commands: ['notify-send']

	notify: (backend, perc, disabled, text, cb) ->
		args = [
			"--icon=#{@_icon(backend, perc, disabled)}"
			"--expire-time=#{@config.notify.timeout}"
			"--hint=string:synchronous:#{backend}"
		]
		switch @config.notify.style
			when 'ascii'
				args.push "#{backend}: #{perc}"
				if text
					args.push text
				else
					args.push "<big><tt>#{@_ascii_bar @_relative_percent perc, backend}</tt></big>"
			when 'value'
				args.push "#{backend} #{perc}"
			when 'progress'
				args.push "--hint=int:value:#{@_relative_percent(perc, backend)}"
				if text
					args.push text
				else
					args.push "#{backend}: #{perc}"
		@_exec 'notify-send', args, cb
