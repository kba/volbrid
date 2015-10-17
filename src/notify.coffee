Errors = require './errors'
Extend = require 'node.extend'
CmdExecutor = require './cmd_executor'
module.exports = class Notify extends CmdExecutor

	_ascii_bar: (perc, disabled=false, backend='_default') ->
		opts = {}
		Extend opts, @config.notify.asciibar
		Extend opts, @config.providers[backend].asciibar
		bar = ''
		fillmax = (perc / 100) * opts.width
		for i in [0 ... fillmax]
			ch = opts.fillchar
			if not opts.use_colors
				bar += ch
				continue
			if disabled or perc <= 0
				bar += "<span color='#{opts.colors.off}'>#{ch}</span>"
			else if disabled or perc <= opts.thresholds[0]
				bar += "<span color='#{opts.colors.low}'>#{ch}</span>"
			else if disabled or perc <= opts.thresholds[1]
				bar += "<span color='#{opts.colors.medium}'>#{ch}</span>"
			else
				bar += "<span color='#{opts.colors.high}'>#{ch}</span>"
		for i in [fillmax+1 ... opts.width]
			bar += opts.emptychar
		return "#{opts.delimleftchar}#{bar}#{opts.delimrightchar}"

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
