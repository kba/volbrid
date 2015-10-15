Chokidar = require 'chokidar'
Extend   = require 'node.extend'
Fs       = require 'fs'
MkdirP   = require 'mkdirp'
Net      = require 'net'
Pwuid    = require 'pwuid'
YAML     = require 'yamljs'
{UNKNOWN_COMMAND, UNKNOWN_BACKEND} = require './errors'

XDG_CONFIG_HOME_CONFIG = "#{process.env.HOME}/.config/volbrid.yml"
CONFIG_FILES = [
	"#{__dirname}/../builtin.yml"
	"/etc/volbrid.yml"
	XDG_CONFIG_HOME_CONFIG
]

module.exports = class Daemon

	constructor: (@options) ->
		@username = Pwuid().name
		@socket_path = "/tmp/#{@username}/volbrid.sock"
		@reload_config()
		@watch_config_files()

	watch_config_files : () ->
		console.log "Watching file #{XDG_CONFIG_HOME_CONFIG}"
		@watcher = Chokidar.watch XDG_CONFIG_HOME_CONFIG, {
			persistent: false
		}
		@watcher.on 'change', (path) ->
			console.log "Config file #{path} changed. Reloading config"
			reload_config()

	unwatch_config_files: () ->
		console.log "Unwatching file #{XDG_CONFIG_HOME_CONFIG}"
		@watcher.unwatch XDG_CONFIG_HOME_CONFIG
		@watcher.close()

	reload_config: (args) ->
		@config = {}
		for path in CONFIG_FILES
			if Fs.existsSync path
				console.log "Merging config from #{path}"
				@config = Extend(true, @config, YAML.load(path))
			for k,v of @config.providers
				continue if k is '_default'
				_defaultClone = Extend true, {}, @config.providers._default
				@config.providers[k] = Extend(true, _defaultClone, v)

	get_backend: (type) ->
		backend_config = if type is 'notify' then @config.notify else @config.providers[type]
		if backend_config.backend
			console.log "Force load './#{type}/#{backend_config.backend}' because 'backend' overrides order"
			mod = require("./#{type}/#{backend_config.backend}")
			return new mod(@config)
		e = "No backend defined for '#{type}'"
		for modName in backend_config.order
			try
				mod = require("./#{type}/#{modName}")
				return new mod(@config)
			catch innerE
				e = innerE
				continue
		console.log "Failed to load a backend for '#{type}': #{e}"

	list_backends: (backend_type) ->
		ret = []
		for k,v of @config.providers
			if typeof v is 'object' and k isnt '_default'
				ret.push k
		return ret

	get_all_backends: ->
		backends = {}
		for backend in @list_backends()
			backends[backend] = @get_backend backend
		backends.notify = @get_backend 'notify'
		return backends

	call_backend: (backend, cmd, val) ->
		if not @config.providers[backend]
			UNKNOWN_BACKEND backend, @list_backends()
		val or= @config.providers[backend].step
		backends = @get_all_backends()
		show = ->
			backends[backend].get (err, perc, disabled, text) ->
				backends.notify.notify backend, perc, disabled, text
		switch cmd
			when 'show', 'get'
				show()
			when 'inc', 'up'
				backends[backend].inc val, show
			when 'dec', 'down'
				backends[backend].dec val, show
			when 'set'
				backends[backend].set val, show
			when 'toggle'
				backends[backend].toggle show
			else
				UNKNOWN_COMMAND cmd, backend

	start: (already_retried) ->
		self = @
		server = Net.createServer (sock) ->
			sock.on 'data', (data) ->
				str = data.toString().replace /\n/g, ''
				args = str.split /\s+/
				console.log "RCVD: [#{args}]"
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
