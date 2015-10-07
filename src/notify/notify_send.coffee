ChildProcess = require 'child_process'
Notify = require '../notify'
module.exports = class NotifySend extends Notify

	notifyVolume: (perc, cb) ->
		args = [
			"Volume"
			"--icon=#{@_icon_for_volume(perc)}"
			"--expire-time=#{@config.notify_send.timeout}"
		]
		if @config.notify_send.style == 'value-hint'
			args.push "--hint=int:value:#{perc}"
			args.push "--hint=string:synchronous:volume"

		notify_send = ChildProcess.spawn 'notify-send', args
		notify_send.on 'exit', (err) ->
			throw err if err
			cb null

