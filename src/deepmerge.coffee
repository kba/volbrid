module.exports = deepmerge = (target, src) ->
	array = Array.isArray(src)
	dst = array and [] or {}
	if array
		target = target or []
		dst = dst.concat(target)
		src.forEach (e, i) ->
			if typeof dst[i] == 'undefined'
				dst[i] = e
			else if typeof e == 'object'
				dst[i] = deepmerge(target[i], e)
			else
				if target.indexOf(e) == -1
					dst.push e
			return
	else
		if target and typeof target == 'object'
			Object.keys(target).forEach (key) ->
				dst[key] = target[key]
				return
		Object.keys(src).forEach (key) ->
			if typeof src[key] != 'object' or !src[key]
				dst[key] = src[key]
			else
				if !target[key]
					dst[key] = src[key]
				else
					dst[key] = deepmerge(target[key], src[key])
			return
	dst
