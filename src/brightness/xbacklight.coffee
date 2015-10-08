ChildProcess = require 'child_process'
Brightness = require '../brightness'
module.exports = class Xbacklight extends Brightness

	get: (cb) ->
		args = ['-get']
		cmd = ChildProcess.spawn 'xbacklight', args
		cmd.stdout.on 'data', (data) ->
			cb null, data
		if @config.debug
			cmd.stdout.on 'data', (data) -> console.log "[xbacklight #{args}]\nSTDOUT: #{data}"
			cmd.stderr.on 'data', (data) -> console.log "[xbacklight #{args}]\nSTDERR: #{data}"
		cmd.on 'error', (err) -> console.log cb err
	
	inc: (perc, cb) -> @_xbacklight ['-inc', "+#{perc}"], cb

	dec: (perc, cb) -> @_xbacklight ['-dec', "-#{perc}"], cb

	set: (perc, cb) -> @_xbacklight ['-set', "-#{perc}"], cb

	_xbacklight: (args, cb) ->
		cmd = ChildProcess.spawn 'xbacklight', args
		if @config.debug
			cmd.stdout.on 'data', (data) -> console.log "[xbacklight #{args}]\nSTDOUT: #{data}"
			cmd.stderr.on 'data', (data) -> console.log "[xbacklight #{args}]\nSTDERR: #{data}"
		cmd.on 'error', (err) -> throw err
		cmd.on 'exit', cb
