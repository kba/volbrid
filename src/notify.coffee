Errors = require './errors'
Extend = require 'node.extend'
CmdExecutor = require './cmd_executor'
module.exports = class Notify extends CmdExecutor

	_ascii_bar: (perc, disabled=false, backend='_default') ->
		opts = {}
		Extend opts, @config.notify.asciibar
		Extend opts, @config.providers[backend].asciibar
		fillmax = Math.ceil(perc * opts.width / 100)
		filled = Array(fillmax+1).join(opts.fillchar)
		bar = opts.left
		if not opts.use_colors
			bar += filled
		else
			if perc >= 100
				color = opts.colors[opts.colors.length-1]
			else
				for c, i in opts.colors
					break if i * (100/(opts.colors.length-1)) > perc
					color = opts.colors[i+1]
			bar += "<span color='#{color}'>#{filled}</span>"
		if fillmax < opts.width
			for i in [fillmax+1 .. opts.width]
				bar += opts.emptychar
		bar += opts.right
		return bar

	_relative_percent: (perc, backend) ->
		return Math.min(100, perc * (100 / @config.providers[backend].max))

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
