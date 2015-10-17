Chokidar = require 'chokidar'
Extend   = require 'node.extend'
Fs       = require 'fs'
MkdirP   = require 'mkdirp'
Net      = require 'net'
Pwuid    = require 'pwuid'
Daemon   = require 'daemon'
YAML     = require 'yamljs'
{UNKNOWN_COMMAND, UNKNOWN_BACKEND} = require './errors'

BUILTIN_CONFIG = "#{__dirname}/../builtin.yml"
ETC_CONFIG = "/etc/volbrid.yml"
HOME_CONFIG = "#{process.env.HOME}/.config/volbrid.yml"

module.exports = class Daemon

	constructor: (@options) ->
		@username = Pwuid().name
		@socket_path = "/tmp/#{@username}/volbrid.sock"
		@notify = null
		@providers = {}
		@config = {}
		@reload_config()
		@watch_config_files()

	watch_config_files : () ->
		console.log "Watching file #{HOME_CONFIG}"
		@watcher = Chokidar.watch HOME_CONFIG, {
			persistent: false
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

	load_executor: (type) ->
		backend_config = if type is 'notify' then @config.notify else @config.providers[type]
		if backend_config.backend
			modPath = "./#{type}/#{backend_config.backend}"
			mod = require(modPath)
			console.log "Loaded #{modPath}"
			return new mod(@config)
		e = null
		for modName in backend_config.order
			try
				modPath = "./#{type}/#{modName}"
				mod = require(modPath)
				console.log "Loaded #{modPath}"
				return new mod(@config)
			catch innerE
				console.log "Could not load #{type}/#{modName}"
				e = innerE
				continue
		console.log "Failed to load a backend for '#{type}': #{e}"

	list_providers: () ->
		ret = []
		for k, v of @config.providers
			if typeof v is 'object' and k isnt '_default'
				ret.push k
		return ret

	call_backend: (backend, cmd, val) ->
		if not @config.providers[backend]
			UNKNOWN_BACKEND backend, @list_providers()
		val or= @config.providers[backend].step
		self = @
		show = =>
			self.providers[backend].get (err, perc, disabled, text) =>
				self.notify.notify backend, perc, disabled, text
		switch cmd
			when 'show', 'get'
				show()
			when 'inc', 'up'
				@providers[backend].inc val, show
			when 'dec', 'down'
				@providers[backend].dec val, show
			when 'set'
				@providers[backend].set val, show
			when 'toggle'
				@providers[backend].toggle show
			else
				UNKNOWN_COMMAND cmd, backend

	start: (already_retried) ->
		self = @
		server = Net.createServer (sock) ->
			sock.on 'data', (data) ->
				str = data.toString().replace /\n/g, ''
				args = str.split /\s+/
				console.log "<-: [#{args}]"
				switch args[0]
					when 'reload'
						reload_config(args[1..])
						sock.write 'Reloaded config'
					when 'debug'
						sock.write YAML.stringify @config
					when 'quit'
						self.stop()
					else
						try
							self.call_backend.apply(self, args)
						catch e
							console.log e
							sock.write e
		server.on 'listening', ->
			return Fs.chmod(self.socket_path, 0o0777)
		server.on 'error', ->
			self.stop()
			if not already_retried
				self.start(true)
		MkdirP "/tmp/#{@username}", (err) ->
			throw "Could not create /tmp/#{self.username}" if err
			server.listen self.socket_path, () ->
				console.log "Listening on #{self.socket_path}"

	remove_socket: () ->
		console.log 'Remove socket'
		Fs.unlinkSync(@socket_path)

	stop: ->
		@unwatch_config_files()
		@remove_socket()
