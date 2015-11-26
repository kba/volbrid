{NOT_IMPLEMENTED} = require './common'
Extend = require 'node.extend'
CliTable = require 'cli-table'

class Message

	constructor : (opts, _required) ->
		if not opts
			throw "Usage: new Message({sender:'foo',...)"
		_required.push v for v in ['provider', 'backend', 'config']
		for k in _required
			if k not of opts
				throw NOT_IMPLEMENTED @constructor.name, k, Message
		@[k] = v for k,v of opts

	format : (format, args...) ->
		fnName = "_format_#{format.replace /[^a-z]/g, '_'}"
		fn = @[fnName]
		if typeof fn isnt 'function'
			NOT_IMPLEMENTED @constructor.name, fnName
			return
		return fn.apply(@, args)

class ValueMessage extends Message

	constructor : (opts, _required) ->
		_required or= ['value', 'disabled', 'max']
		super(opts, _required)

	_format_relative_percent : () ->
		return Math.min(100, @value * (100 / @max))

	_format_ascii_bar: () ->
		opts = {}
		Extend opts, @config.notify.asciibar
		Extend opts, @config.providers[@provider].asciibar
		perc = @format 'relative-percent'
		fillmax = Math.ceil(perc * opts.width / 100)
		filled = Array(fillmax+1).join(opts.fillchar)
		bar = opts.left
		if not opts.use_colors or @disabled
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

	_format_icon: () ->
		provider_config = @config.providers[@provider]
		return if provider_config.no_icon
		if @disabled or @value == provider_config.off_value
			return provider_config.icons.off
		else if @value <= provider_config.thresholds[0]
			return provider_config.icons.low
		else if @value <= provider_config.thresholds[1]
			return provider_config.icons.medium
		else
			return provider_config.icons.high


class GridMessage extends ValueMessage

	constructor : (opts, _required) ->
		_required or= ['nr_cols', 'nr_rows']
		super(opts, _required)
	
	_format_ascii_grid : (opts) ->
		desktop_idx = 0
		out = ''
		color= '#ff0000'
		for y in [0 ... @nr_rows]
			for x in [0 ... @nr_cols * 6]
				out += '-'
			out += '\n'
			for x in [0 ... @nr_cols]
				if @value == desktop_idx
					sym = "<span color='#{color}'>*</span>#{desktop_idx}<span color='#{color}'>*</span>"
				else
					sym = " #{desktop_idx} "
				if @windows_per_desktop[desktop_idx]
					out += "#{sym}[#{@windows_per_desktop[desktop_idx]}]"
				else 
					out += " #{sym}  "
				if x < @nr_cols
					out += "|"
				desktop_idx += 1
			out += '\n'
		for x in [0 ... @nr_cols * 6]
			out += '-'
		out += '\n'
		return out

module.exports = {
	ValueMessage
	GridMessage
}
