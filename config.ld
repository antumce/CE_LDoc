title = 'Cheat Engine Docs'
project = 'Cheat Engine'
dir = 'docs'
not_luadoc = true
format = 'markdown'
sort = true
file = {
	'classes',
	'functions',
}

local function createStringBuilder(var)
	local ret = {}
	ret.strings = {}

	ret.append = function(str)
		table.insert(ret.strings, str)
	end

	ret.insert = function(idx, str)
		if type(idx) == 'string' and str == nil then
			str = idx
			idx = 1
		elseif idx == nil then idx = 1 end
		table.insert(ret.strings, idx, str)
	end

	ret.prepend = function(str)
		table.insert(ret.strings, 1, str)
	end

	ret.tostring = function()
		return table.concat(ret.strings)
	end

	if var == nil then
		return ret
	else
		var = ret
	end
end

local function indent(text)
	return '<div style="text-indent:25px;">' .. text .. '</div>'
end

-- custom types
new_type('subclass', 'Inheritance')
new_type('prop', 'Properties')
alias('inherits', 'subclass')

-- custom tags
custom_tags = {
	{
		'ptype',
		title = 'Type',
		format = function(item)
			local prop_types = {
				string = { url = 'https://www.lua.org/manual/5.3/manual.html#6.4' },
				table = { url = 'https://www.lua.org/manual/5.3/manual.html#6.6' },
			}
			local first = string.split(item, ' ')[1]
			if first == nil then
				quit('"ptype" requires a value')
			end
			local last = item:sub(#first+1)
			local sb = createStringBuilder()
			sb.insert(first)
			if table.contains(prop_types, first) then
				sb.prepend('\n\t<a href="' .. prop_types[first].url .. '">')
				sb.append('</a>\n')
			end
			if last ~= nil then
				sb.append(last)
			end
			-- indenting looks bad for multiple types
			-- FIXME: Only allow once instance
			--sb.prepend('<div style="text-indent:25px; font-style:italic;">')
			sb.prepend('<div style="font-style:italic;">')
			sb.append('</div>')

			return sb.tostring()
		end,
	},
	{
		'idx',
		hidden = true,
		title = 'Index',
	},
}

local function name_cropping_handler(item, default_handler, delim)
	if delim == nil then delim = '.' end

	local basename = nil
	if string.find(item.name, delim) then
		local s = string.split(item.name, delim)
		if #s > 1 then
			basename = s[2]
		end
	end

	if basename ~= nil then
		if item.type == 'prop' and (item.tags.idx or (item.tags.ptype and item.tags.ptype[1] == 'array')) then
			local sb = createStringBuilder()
			sb.append(basename)
			if not item.tags.idx then
				sb.append(' []')
			else
				sb.append(' [ ')
				local count = 0
				for _, T in pairs(item.tags.idx) do
					count = count + 1
					if count == #item.tags.idx then
						sb.append('<i>' .. T .. '</i>')
					else
						sb.append('<i>' .. T .. '</i>, ')
					end
				end
				sb.append(' ]')
			end
			basename = sb.tostring()
		end

		return basename
	end

	return default_handler(item)
end

local function function_display_handler(item, default_handler)
	local ret = name_cropping_handler(item, default_handler, ':')

	local sb = createStringBuilder()
	sb.append(ret)
	if #item.params == 0 then
		sb.append(' ()')
	else
		sb.append(' ( ')
		local count = 0
		for _, p in ipairs(item.params) do
			count = count + 1
			if count == #item.params then
				sb.append('<i>' .. p .. '</i>')
			else
				sb.append('<i>' .. p .. '</i>, ')
			end
		end
		sb.append(' )')
	end

	return sb.tostring()
end

custom_display_name_handler = function(item, default_handler)
	for _, T in pairs({'subclass', 'prop',}) do
		if item.type == T then
			return name_cropping_handler(item, default_handler)
		end
	end

	if item.type == 'function' then
		return function_display_handler(item, default_handler)
	end

	return default_handler(item)
end
