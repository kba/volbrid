Pwuid    = require 'pwuid'

username = Pwuid().name
module.exports =
	SOCKET_PATH: "/tmp/#{username}/volbrid.sock"
	NOT_IMPLEMENTED: (klass, method, super_klass) ->
		throw "#{klass} must implement method #{method} of #{super_klass}."
	UNKNOWN_BACKEND_COMMNAND: (cmd, backend, provider) ->
		"Unknown command '#{cmd}' for backend '#{backend}' of provider '#{provider}'"
	UNKNOWN_PROVIDER: (backend, supported_providers) ->
		"Unknown provider '#{provider}'. Supported providers: #{supported_providers.join(', ')}"

