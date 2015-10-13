{NOT_IMPLEMENTED} = require './errors'
CmdExecutor = require './cmd_executor'
module.exports = class Backend extends CmdExecutor

	toggle: (cb)    -> NOT_IMPLEMENTED @constructor.name, 'toggle', CmdExecutor
	get: (cb)       -> NOT_IMPLEMENTED @constructor.name, 'get', CmdExecutor
	set: (perc, cb) -> NOT_IMPLEMENTED @constructor.name, 'set', CmdExecutor
	inc: (perc, cb) -> NOT_IMPLEMENTED @constructor.name, 'inc', CmdExecutor
	dec: (perc, cb) -> NOT_IMPLEMENTED @constructor.name, 'dec', CmdExecutor
