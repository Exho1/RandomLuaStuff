if SERVER then
	AddCSLuaFile()
end

js = {}
js.convertedLua = {}
js.addedLines = 0

local find = string.find
local sub = string.sub
local gsub = string.gsub
local format = string.format

function js.parse( tbl, key, line )
	--print("Line: "..key..":",line)
	line = string.Trim( line )
	local lineLength = string.len(line)
	
	if find(line, ";") then
		local sStart, sEnd = find(line, ";")

		local postSemiColon = sub( line, sEnd + 1 )
		postSemiColon = string.Trim( postSemiColon )
		if postSemiColon != "" then
			-- Multiple declarations on one line, send the declaration to the next key
			--print("Characters after semicolon - "..tostring(postSemiColon))
			table.insert(tbl, key+1, postSemiColon)
			line = sub(line, 1, sEnd)
			js.addedLines = js.addedLines + 1
		end
		
		line = gsub(line, ";", "")
	end
	
	if find(line, "%w%s?=%s?%w") then
		--print("Variable declaration")
		if find(line, "var") then
			--print("- Local variable")
			-- Line is a declaration
			local vStart, vEnd = find(line, "var")
			local eStart, eEnd = find(line, "=")
			
			local variable = sub(line, vEnd + 1, eStart - 0 )
			local value = sub(line, eEnd + 1 )
			variable = gsub(variable, "=", "")
			value = gsub(value, "=", "")
			
			return format( "local %s = %s", variable, value )
		else
			--print("- Global or extending local")
			local eStart, eEnd = find(line, "=")
			local variable = sub(line, 2, eStart - 0 )
			local value = sub(line, eEnd + 1 )
			variable = gsub(variable, "=", "")
			value = gsub(value, "=", "")
			
			return format( "%s = %s", variable, value )
		end
	elseif find(line, "if %(?.%)?") then
		--print("If statement")
		
		-- Count how many brackets exist to see if any are missing
		local openCount, closeCount = 0, 0 
		local lineTbl = string.Explode("", line)
		for _, v in pairs(lineTbl) do
			if string.find( v, "%(") then
				openCount = openCount + 1
			end
			
			if string.find( v, "%)") then
				closeCount = closeCount + 1
			end
		end
		
		-- A bracket is missing or has been added where it should not be
		if openCount != closeCount then
			if openCount > closeCount then
				error( format( "Missing ')' in JavaScript at line '%i' \n", key - js.addedLines ) )
			else
				error( format( "Missing '(' in JavaScript at line '%i' \n", key - js.addedLines ) )
			end
		end
		
		-- Catch 'else if'
		if find(line, "else if") then
			if find(line, "%(*[^%w]*%)%s*") and not find(line, "%(*[^%w]*%) {") then
				if string.Trim(tbl[key+1]) == "{" then
					table.remove(tbl, key+1) -- Remove the next entry, its only an open bracket
					js.addedLines = js.addedLines - 1
				end
			end
			
			local p1Start, p1End = find(line, "%(") -- First open bracket
			local p2Start, p2End = find(line:reverse(), "%)*") -- First open bracket from end
			p2Start, p2End = lineLength - p2Start, lineLength - p2End -- Get proper positions 
			
			local contents = sub(line, p1End, p2Start)
			
			return format("elseif ( %s ) then", contents)
		end
		
		if find(line, "%(*[^%w]*%)") then
			if find(line, "%(*[^%w]*%)%s*") and not find(line, "%(*[^%w]*%) {") then
				if string.Trim(tbl[key+1]) == "{" then
					--print("- New line bracket")
					table.remove(tbl, key+1) -- Remove the next entry, its only an open bracket
					js.addedLines = js.addedLines - 1
				end
			end
			
			local p1Start, p1End = find(line, "%(") -- First open bracket
			local p2Start, p2End = find(line:reverse(), "%)*") -- First open bracket from end
			p2Start, p2End = lineLength - p2Start, lineLength - p2End -- Get proper positions 
			
			-- Grab contents of parenthesis and return them in parenthesis
			local contents = sub(line, p1End, p2Start)
			
			return format( "if ( %s ) then", contents )
		end

	elseif find(line, "else") then -- Else on a new line
		return "else"
	elseif find(line, "%w%s?%(.*") then -- A function or method
		return line
	elseif find(line, "}") then -- Closing bracket for a loop or if then block
		if find(tbl[key+1], "else") then -- If there is an else on the next line, dont end
			table.remove(tbl, key)
		else
			return "end"
		end
	end
	
	if find(line, "{") then -- A stray bracket that wasn't caught by anything
		--print("Lone bracket")
		table.remove(tbl, key)
		js.addedLines = js.addedLines - 1
	end
end

function js.includeJS( filePath )
	local contents = file.Read( filePath, "LUA" )
	js.addedLines = 0
	
	local lines = string.Explode("\n", contents)
	for key, line in pairs( lines ) do
		local lua = js.parse( lines, key, line)
		table.insert(js.convertedLua, lua)
	end

	local lua = table.concat( js.convertedLua, "	")
	RunString( lua )
end

--js.includeJS( "autorun/test.js" )
