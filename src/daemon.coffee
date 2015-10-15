Chokidar = require 'chokidar'
Extend   = require 'node.extend'
Fs       = require 'fs'
MkdirP   = require 'mkdirp'
Net      = require 'net'
Pwuid   = require 'pwuid'
YAML     = require 'yamljs'
{UNKNOWN_COMMAND, UNKNOWN_BACKEND} = require './errors'

USERNAME = Pwuid().name
SOCKET_PATH = "/tmp/#{USERNAME}/volbrid.sock"
XDG_CONFIG_HOME_CONFIG = "#{process.env.HOME}/.config/volbrid.yml"
CONFIG_FILES = [
	"#{__dirname}/../builtin.yml"
	"/etc/volbrid.yml"
	XDG_CONFIG_HOME_CONFIG
]

CONFIG = {}
WATCHER = null

watch_config_files = () ->
	WATCHER = Chokidar.watch XDG_CONFIG_HOME_CONFIG, {
		persistent: false
	}
	console.log "Watching file #{XDG_CONFIG_HOME_CONFIG}"
	WATCHER.on 'change', (path) ->
		console.log "Config file #{path} changed. Reloading config"
		load_config()

unwatch_config_files = () ->
	console.log "Unwatching file #{XDG_CONFIG_HOME_CONFIG}"
	WATCHER.unwatch XDG_CONFIG_HOME_CONFIG
	WATCHER.close()

load_config = (args) ->
	for path in CONFIG_FILES
		if Fs.existsSync path
			console.log "Merging config from #{path}"
			CONFIG = Extend(true, CONFIG, YAML.load(path))
		for k,v of CONFIG.providers
			continue if k is '_default'
			_defaultClone = Extend true, {}, CONFIG.providers._default
			CONFIG.providers[k] = Extend(true, _defaultClone, v)

get_backend = (type) ->
	backend_config = if type is 'notify' then CONFIG.notify else CONFIG.providers[type]
	if backend_config.backend
		console.log "Force load './#{type}/#{backend_config.backend}' because 'backend' overrides order"
		mod = require("./#{type}/#{backend_config.backend}")
		return new mod(CONFIG)
	e = "No backend defined for '#{type}'"
	for modName in backend_config.order
		try
			mod = require("./#{type}/#{modName}")
			return new mod(CONFIG)
		catch innerE
			e = innerE
			continue
	console.log "Failed to load a backend for '#{type}': #{e}"

list_backends = (backend_type) ->
	ret = []
	for k,v of CONFIG.providers
		if typeof v is 'object' and k isnt '_default'
			ret.push k
	return ret

get_all_backends = ->
	backends = {}
	for backend in list_backends()
		backends[backend] = get_backend backend
	backends.notify = get_backend 'notify'
	return backends

call_backend = (backend, cmd, val) ->
	if not CONFIG.providers[backend]
		UNKNOWN_BACKEND backend, list_backends()
	val or= CONFIG.providers[backend].step
	backends = get_all_backends()
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

load_config(process.argv)
watch_config_files()

start_server = (already_retried) ->
	server = Net.createServer (sock) ->
		sock.on 'data', (data) ->
			str = data.toString().replace /\n/g, ''
			args = str.split /\s+/
			console.log "RCVD: [#{args}]"
			switch args[0]
				when 'reload'
					load_config(args[1..])
					sock.write 'Reloaded config'
				when 'debug'
					sock.write YAML.stringify CONFIG
				when 'quit'
					stop_server()
					exit()
				else
					try
						call_backend.apply(@, args)
					catch e
						sock.write e
	server.on 'listening', ->
		return Fs.chmod(SOCKET_PATH, 0o0777)
	server.on 'error', ->
		stop_server()
		if not already_retried
			start_server(true)
	MkdirP "/tmp/#{USERNAME}", (err) ->
		throw "Could not create /tmp/#{USERNAME}" if err
		server.listen SOCKET_PATH, () ->
			console.log "Listening on #{SOCKET_PATH}"

stop_server = ->
	unwatch_config_files()
	console.log 'Remove socket'
	Fs.unlinkSync(SOCKET_PATH)

process.on 'SIGINT', ->
	console.log 'Received SIGINT'
	stop_server()
	exit()

exit = ->
	console.log 'Exit'
	process.exit()

start_server()
