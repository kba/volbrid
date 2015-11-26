{NOT_IMPLEMENTED} = require './common'
CmdExecutor = require './cmd_executor'
module.exports = class Notify extends CmdExecutor

	_relative_percent: (perc, backend) ->
		return Math.min(100, perc * (100 / @config.providers[backend].max))

	_timeout_in_seconds: () ->
		Math.ceil(@config.notify.timeout / 1000)

	notify : (backend, msg, cb) ->
		NOT_IMPLEMENTED(@constructor.name, 'notify', Notify)
