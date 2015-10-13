Errors = require './errors'
CmdExecutor = require './cmd_executor'
module.exports = class Notify extends CmdExecutor

	_timeout_in_seconds: () ->
		Math.ceil(@config.notify.timeout / 1000)

	_icon: (backend, perc, disabled) ->
		backend_config = @config.providers[backend]
		if disabled or perc == backend_config.off_value
			return backend_config.icons.off
		else if perc <= backend_config.thresholds[0]
			return backend_config.icons.low
		else if perc <= backend_config.thresholds[1]
			return backend_config.icons.medium
		else
			return backend_config.icons.high

	notify : (backend, perc, disabled, text, cb) ->
		Errors.NOT_IMPLEMENTED(@constructor.name, 'notify', Notify)
