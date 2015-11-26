{NOT_IMPLEMENTED} = require './common'
CmdExecutor = require './cmd_executor'
{ValueMessage, GridMessage} = require './message'

module.exports = class Backend extends CmdExecutor

	toggle: (cb)    -> NOT_IMPLEMENTED @constructor.name, 'toggle', CmdExecutor
	get: (cb)       -> NOT_IMPLEMENTED @constructor.name, 'get', CmdExecutor
	set: (perc, cb) -> NOT_IMPLEMENTED @constructor.name, 'set', CmdExecutor
	inc: (perc, cb) -> NOT_IMPLEMENTED @constructor.name, 'inc', CmdExecutor
	dec: (perc, cb) -> NOT_IMPLEMENTED @constructor.name, 'dec', CmdExecutor

	_createGridMessage : (opts) ->
		@__ensureValueOpts(opts)
		opts.nr_cols = @config.providers[opts.provider].nr_cols
		opts.nr_rows = @config.providers[opts.provider].nr_rows
		opts.things_in_grid = new Array(opts.max + 1)
		return new GridMessage(opts)

	__ensureValueOpts : (opts) ->
		opts.config = @config
		opts.backend or= @constructor.name.toLowerCase()
		opts.disabled or= false
		opts.max or= @config.providers[opts.provider].max

	_createValueMessage : (opts) ->
		@__ensureValueOpts(opts)
		return new ValueMessage(opts)
