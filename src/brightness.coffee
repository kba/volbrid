CmdExecutor = require './cmd_executor'
module.exports = class Brightness extends CmdExecutor

	constructor: (@config) ->

	get: (cb) ->
		throw "Not implemented"

	inc: (perc, cb) ->
		throw "Not implemented"

	dec: (perc, cb) ->
		throw "Not implemented"

	set: (perc, cb) ->
		throw "Not implemented"
