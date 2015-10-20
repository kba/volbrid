Chokidar = require 'chokidar'
Extend   = require 'node.extend'
Fs       = require 'fs'
MkdirP   = require 'mkdirp'
Net      = require 'net'
Daemon   = require 'daemon'
Path     = require 'path'
YAML     = require 'yamljs'
{SOCKET_PATH, UNKNOWN_BACKEND_COMMNAND, UNKNOWN_PROVIDER} = require './common'

BUILTIN_CONFIG = "#{__dirname}/../builtin/volbrid.yml"
ETC_CONFIG = "/etc/volbrid.yml"
HOME_CONFIG = "#{process.env.HOME}/.config/volbrid.yml"

module.exports = class Daemon

	constructor: (@options) ->
		@providers = {}
		@is_started = false
		@active_providers = {}
		@config = {}

	watch_config_files : () ->
		console.log "Watching file #{HOME_CONFIG}"
		@watcher = Chokidar.watch HOME_CONFIG, {
			persistent: true
		}
		@watcher.on 'change', (path) =>
			console.log "Config file #{path} changed. Reloading config"
			@reload_config()

	unwatch_config_files: () ->
		console.log "Unwatching file #{HOME_CONFIG}"
		@watcher.unwatch HOME_CONFIG
		@watcher.close()

	reload_config: (args) ->
		@config = YAML.load(BUILTIN_CONFIG)
		for path in [ETC_CONFIG, HOME_CONFIG]
			if Fs.existsSync path
				console.log "Merging config from #{path}"
				@config = Extend(true, @config, YAML.load(path))
			for k,v of @config.providers
				continue if k is '_default'
				_defaultClone = Extend true, {}, @config.providers._default
				@config.providers[k] = Extend(true, _defaultClone, v)
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

	load_executor: (type) ->
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
		if @active_providers[provider] is true
			console.log "[SKIP #{[provider,cmd,val]}: Modal backend and still active_providers."
			return
		else
			@active_providers[provider] = true
		_show = =>
			@providers[provider].get (err, perc, disabled, text) =>
				@active_providers[provider] = false
				@notify.notify provider, perc, disabled, text
		cmd or= 'get'
		val or= @config.providers[provider].step
		switch cmd
			when 'show', 'get'
				_show()
			when 'inc', 'up'
				@providers[provider].inc val, _show
			when 'dec', 'down'
				@providers[provider].dec val, _show
			when 'set'
				@providers[provider].set val, _show
			when 'toggle'
				@providers[provider].toggle _show
			else
				@active_providers[provider] = false
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
					@reload_config(args[1..])
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

	start: (already_retried) ->
		@reload_config()
		@watch_config_files()
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
				@start(true)
		MkdirP Path.dirname(SOCKET_PATH), (err) =>
			throw "Could not create #{Path.dirname(SOCKET_PATH)}" if err
			@server.listen SOCKET_PATH, () =>
				console.log "Listening on #{SOCKET_PATH}"

	stop: ->
		@unwatch_config_files()
		console.log 'Shutting down server'
		@server.close()
