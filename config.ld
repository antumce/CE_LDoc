title = 'Cheat Engine Docs'
project = 'Cheat Engine'
dir = 'docs'
not_luadoc = true
format = 'markdown'
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
new_type('prop', 'Properties')

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
}
