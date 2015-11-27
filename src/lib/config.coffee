Chokidar = require 'chokidar'
EventEmitter = require('events').EventEmitter
Fs       = require 'fs'
Extend   = require 'node.extend'
YAML     = require 'yamljs'

BUILTIN_CONFIG = "#{__dirname}/../builtin/volbrid.yml"
ETC_CONFIG = "/etc/volbrid.yml"
HOME_CONFIG = "#{process.env.HOME}/.config/volbrid.yml"

module.exports = class Config extends EventEmitter

	_config: {}

	watch_config_files : () ->
		console.log "Watching file #{HOME_CONFIG}"
		@watcher = Chokidar.watch HOME_CONFIG, {
			persistent: true
		}
		@watcher.on 'change', (path) =>
			console.log "Config file #{path} changed. Reloading config"
			@reload()

	unwatch_config_files: () ->
		console.log "Unwatching file #{HOME_CONFIG}"
		@watcher.unwatch HOME_CONFIG
		@watcher.close()

	reload : () ->
		delete @[k] for k,v of @_config
		@_config = YAML.load(BUILTIN_CONFIG)
		for path in [ETC_CONFIG, HOME_CONFIG]
			if Fs.existsSync path
				console.log "Merging config from #{path}"
				@_config = Extend(true, @_config, YAML.load(path))
			for k,v of @_config.providers
				continue if k is '_default'
				_defaultClone = Extend true, {}, @_config.providers._default
				@_config.providers[k] = Extend(true, _defaultClone, v)
		@[k] = v for k,v of @_config
		@emit 'reload'
