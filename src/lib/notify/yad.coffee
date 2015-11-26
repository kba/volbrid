{ValueMessage, GridMessage} = require '../message'
Notify = require '../notify'
YAD = 'yad'
module.exports = class Yad extends Notify

	_commands: [YAD]

	notify: (msg, cb) ->
		cb 'no message to notify' unless msg
		args = [
			"--on-top"
			"--no-buttons"
			"--center"
			"--splash"
			"--skip-taskbar"
			"--undecorated"
			"--sticky"
			"--timeout=#{@_timeout_in_seconds()}"
		]
		if msg.format 'icon'
			args.push "--image=#{msg.format 'icon'}"
		switch @config.notify.style
			when 'progress'
				args.push "--progress"
				args.push "--progress-text=#{msg.provider} #{msg.value}%"
				args.push "--percentage=#{@msg.format 'relative-percent'}"
			when 'ascii'
				if msg instanceof GridMessage
					args.push "--text=<big><tt>#{msg.format 'ascii-grid'}</tt></big>"
				else
					args.push "--text=<big><tt>#{msg.provider}: #{msg.value}%</tt></big>" +
					"\n#{msg.format 'ascii-bar'}"
			when 'value'
				args.push "--text=<big><tt>#{msg.provider}: #{msg.value}%</tt></big>"
		if msg.text
			args.push "--text=#{msg.text}"
		@_exec YAD, args, cb
