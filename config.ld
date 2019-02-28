title = 'Cheat Engine Docs'
project = 'Cheat Engine'
dir = 'docs'
not_luadoc = true
format = 'markdown'
sort = true
wrap = true
file = {
	'classes',
	'globals',
}

readme = "README.md"

--- Function to check if a file exists.
--
-- FIXME: Only works if file can be opened for reading.
local function isfile(filename)
	local exists = false
	local f = io.open(filename, 'r')
	if f ~= nil then
		exists = true
		io.close(f)
	end

	return exists
end

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
new_type('global', 'Globals', true)
new_type('subclass', 'Inheritance')
new_type('prop', 'Properties')
alias('inherits', 'subclass')
new_type('def', 'Definition Type')

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
				-- link to external reference
				sb.prepend('\n\t<a href="' .. prop_types[first].url .. '">')
				sb.append('</a>\n')
			elseif isfile('classes/' .. first .. '.ldoc') then
				-- link to local reference
				sb.prepend('\n\t<a href="' .. first .. '.html">')
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
	{
		'value',
		title = 'Possible values',
	},
	{
		-- 'see' tag for creating mauanl links
		'msee',
		title = "See also",
	},
}

custom_see_handler('^c .*', function(value)
	print('CUSTOM SEE HANDLER')
	value = value:sub(3)
	print('Value: ' .. value)
	value = string.split(value, ':')
	local name = value[1]
	local url = value[2]
	print('Name :' .. name)
	print('URL: ' .. url)
	return name, url
end)

local function cropName(name, delim)
	-- default is single period (.)
	if delim == nil then delim = '.' end

	local basename = name
	if string.find(basename, delim) then
		local s = string.split(basename, delim)
		if #s > 1 then
			basename = s[2]
		end
	end

	return basename
end

local function property_display_handler(item)
	basename = cropName(item.name)

	if item.tags.idx or (item.tags.ptype and item.tags.ptype[1] == 'array') then
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

local function function_display_handler(item, default_handler)
	local ret = cropName(item.name, ':')

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

local function subclass_display_handler(item, default_handler)
	for a, b in pairs(item) do
		if a == 'summary' then
			if string.find(b, ' &#x1f844; ') then
				-- TODO: need a method to strip whitespace from strings
				local inherits = string.split(b, ' <- ')
				-- FIXME: better way to use table.concat?
				local sb = createStringBuilder()
				for idx = 1, #inherits, 1 do
					if isfile('classes/' .. inherits[idx] .. '.ldoc') then
						inherits[idx] = '<a href="' .. inherits[idx] .. '.html">' .. inherits[idx] .. '</a>'
					end

					-- FIXME: string.split is not working correctly
					--sb.append(inherits[idx] .. ' &#x1f844; ')
					sb.append(inherits[idx] .. ' ')
				end

				item['summary'] = sb.tostring()
			end
		end
	end

	basename = cropName(item.name)
	return basename
end

custom_display_name_handler = function(item, default_handler)
	if item.type == 'function' then
		return function_display_handler(item, default_handler)
	elseif item.type == 'prop' then
		return property_display_handler(item)
	elseif item.type == 'subclass' then
		return subclass_display_handler(item)
	end

	return default_handler(item)
end
