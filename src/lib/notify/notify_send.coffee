Notify = require '../notify'
module.exports = class NotifySend extends Notify

	_commands: ['notify-send']

	notify: (msg, cb) ->
		args = [
			"--icon=#{msg.format 'icon'}"
			"--expire-time=#{@config.notify.timeout}"
			"--hint=string:synchronous:#{msg.provider}"
		]
		switch @config.notify.style
			when 'ascii'
				args.push "#{msg.backend}: #{msg.value}"
				if msg.text
					args.push msg.text
				else
					args.push "<big><tt>#{msg.format 'ascii-bar'}</tt></big>"
			when 'value'
				args.push "#{msg.provider} #{msg.value}"
			when 'progress'
				args.push "--hint=int:value:#{msg.format 'relative-percent'}"
				if msg.text
					args.push msg.text
				else
					args.push "#{msg.provider}: #{msg.value}"
		@_exec 'notify-send', args, cb
