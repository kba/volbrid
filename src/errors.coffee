module.exports =
	NOT_IMPLEMENTED: (klass, method, super_klass) ->
		throw "#{klass} must implement method #{method} of #{super_klass}."
	UNKNOWN_COMMAND: (cmd, backend) ->
		throw "Unknown command '#{cmd}' for backend '#{backend}'"
	UNKNOWN_BACKEND: (backend, supported_backends) ->
		throw "Unknown backend '#{backend}'. Supported backends: #{supported_backends.join(', ')}"

