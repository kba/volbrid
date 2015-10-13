Fs = require 'fs'
CSON = require 'cson'
Extend = require 'node.extend'
Net = require 'net'
{UNKNOWN_COMMAND, UNKNOWN_BACKEND} = require './errors'
CONFIG = {}
SOCKET_PATH = '/tmp/volbriosd.sock'

load_config = (args) ->
	for path in [
		"#{__dirname}/../default-config.cson"
		"/etc/volbriosd.cson",
		"#{process.env.HOME}/.config/volbriosd.cson"
		"#{process.cwd()}/volbriosd.cson"
		]
		if Fs.existsSync path
			console.log "Merging config from #{path}"
			CONFIG = Extend(true, CONFIG, CSON.load(path))
		for k,v of CONFIG.providers
			continue if k is '_default'
			_defaultClone = Extend true, {}, CONFIG.providers._default
			CONFIG.providers[k] = Extend(true, _defaultClone, v)

get_backend = (type) ->
	backend_config = if type is 'notify' then CONFIG.notify else CONFIG.providers[type]
	if backend_config.backend
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
	throw e

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
# call_backend process.argv[2], process.argv[3], process.argv[4]

start_server = (retry) ->
	server = Net.createServer (sock) ->
		sock.on 'data', (data) ->
			str = data.toString().replace /\n/g, ''
			args = str.split /\s+/
			console.log "RCVD: [#{args}]"
			switch args[0]
				when 'reload'
					load_config(args[1..])
					sock.write 'Reloaded config'
				when 'quit'
					stop_server()
					exit()
				else
					try
						call_backend.apply(@, args)
					catch e
						sock.write e
	server.listen SOCKET_PATH, () ->
		console.log "Listening on #{SOCKET_PATH}"
	server.on 'listening', ->
		return Fs.chmod(SOCKET_PATH, 0o0777)
	server.on 'error', ->
		stop_server()
		if not retry
			start_server(true)

stop_server = ->
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
# TODO argparse
# TODO daemonize

# volume.inc 10, (err) ->
