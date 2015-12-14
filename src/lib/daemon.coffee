Fs       = require 'fs'
MkdirP   = require 'mkdirp'
Net      = require 'net'
Daemon   = require 'daemon'
Path     = require 'path'
{SOCKET_PATH, UNKNOWN_BACKEND_COMMNAND, UNKNOWN_PROVIDER} = require './common'

Config = require './config'

module.exports = class Daemon

	constructor: (@options) ->
		@providers = {}
		@is_started = false
		@active_providers = {}
		@config = new Config(@options)

	apply_config: (args) ->
		for backend in @list_providers()
			@providers[backend] = @load_executor backend
		@notify = @load_executor 'notify'

	_do_require: (type, name) ->
		modPath = "./#{type}/#{name}"
		mod = require(modPath)
		try
			inst = new mod(@config)
			console.log "✓ #{type} -> #{name}"
			inst.name = name
			return inst
		catch e
			console.log "✗ #{type} -> #{name} [#{e}]"

	load_executor:  (type) ->
		backend_config = if type is 'notify' then @config.notify else @config.providers[type]
		if backend_config.backend
			return @_do_require type, backend_config.backend
		e = null
		for name in backend_config.order
			try
				return @_do_require type, name
			catch innerE
				e = innerE
				console.log "✗ #{type} -> #{name} [#{e}]"
				continue
		# console.log "Failed to load a backend for '#{type}': #{e}"

	list_providers: () ->
		ret = []
		for k, v of @config.providers
			if typeof v is 'object' and k isnt '_default'
				ret.push k
		return ret

	get_available_backends: () ->
		ret = {}
		for provider in @list_providers()
			ret[provider] = {}
			for backend in @config.providers[provider].order
				ret[provider][backend] = {
					available: false
					in_use: false
				}
				try
					mod = require "./#{provider}/#{backend}"
					new mod(@config)
					if @providers[provider].name is backend
						ret[provider][backend].in_use = true
					ret[provider][backend].available = true
				catch e
					ret[provider][backend].error = e
		return ret


	call_backend: (provider, cmd, val) ->
		if not @config.providers[provider]
			throw UNKNOWN_PROVIDER provider, @list_providers()
		now = new Date()
		timeout = @active_providers[provider]
		if timeout instanceof Date
			console.log "[SKIP #{[provider,cmd,val]}: Modal backend and still active_providers [Timeout #{timeout}] ."
			if timeout.getTime() >= now.getTime()
				return
			else
				console.log "[SKIP #{[provider,cmd,val]}: Modal timed out, resetting"
		@active_providers[provider] = new Date(now.getTime() + @config.modal_timeout * 1000)
		_show = =>
			@providers[provider].get (err, msg) =>
				delete @active_providers[provider]
				if err
					console.error err
					return
				@notify.notify msg, (err) ->
					console.error "Notify failed", err if err
		cmd or= 'get'
		val or= @config.providers[provider].step
		switch cmd
			when 'show', 'get'
				_show()
			when 'inc'
				@providers[provider].inc val, _show
			when 'dec'
				@providers[provider].dec val, _show
			when 'set'
				@providers[provider].set val, _show
			when 'toggle'
				@providers[provider].toggle _show
			else
				if typeof @providers[provider][cmd] is 'function'
					@providers[provider][cmd] val, _show
				else
					delete @active_providers[provider]
					throw UNKNOWN_BACKEND_COMMNAND cmd, @providers[provider].name, provider

	handle_command: (args) ->
		if @providers[args[0]]
			try
				return @call_backend.apply(@, args)
			catch e
				console.log e
				@socket.write JSON.stringify e
		else
			switch args[0]
				when '--reload'
					@config.reload()
					@socket.write 'Reloaded config'
				when '--get-backends'
					@socket.write JSON.stringify @get_available_backends()
				when '--get-config'
					@socket.write JSON.stringify @config
				when 'quit'
					@socket.write "Shutting down"
					@stop()
				else
					@socket.write JSON.stringify {Error:"Unknown command"}

	_do_start: (already_retried) ->
		@apply_config()
		@server = Net.createServer (sock) =>
			@socket = sock
			@socket.on 'data', (data) =>
				str = data.toString().replace /\n/g, ''
				args = str.split /\s+/
				console.log "RECEIVED: [#{args}]"
				@handle_command(args)
		@server.on 'listening', =>
			@is_started = true
			return Fs.chmod(SOCKET_PATH, 0o0777)
		@server.on 'error', =>
			console.log "Socket already exists, probably unclean shutdown. Removing and restarting"
			Fs.unlinkSync SOCKET_PATH
			if not already_retried
				@_do_start(true)
		MkdirP Path.dirname(SOCKET_PATH), (err) =>
			throw "Could not create #{Path.dirname(SOCKET_PATH)}" if err
			@server.listen SOCKET_PATH, () =>
				console.log "Listening on #{SOCKET_PATH}"

	start: () ->
		@config.once 'reload', => @_do_start()
		@config.reload()
		@config.on 'reload', => @apply_config()

	stop: ->
		@config.removeAllListeners()
		console.log 'Shutting down server'
		@server.close()
