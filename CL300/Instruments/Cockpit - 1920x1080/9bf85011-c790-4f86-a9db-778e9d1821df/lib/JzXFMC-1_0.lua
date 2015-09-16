function findChar(buffer, char, start, finish)
	if start == nil then
		start = 1
	end
    if finish == nil then
        finish = #buffer
    end
    for i = start,finish do
		if buffer[i] == char then
			return i
		elseif buffer[i] == 0 then
			return -1
		end
	end
	return -1
end


function getLargeXfmcString(bytes) 
    local large = "                              "
    local i = findChar(bytes, 47) -- "/"
	if i < 1 then return "" end
	local j = i+1
	local k
	while i < #bytes do
        i = findChar(bytes,59,i+1) -- ";"
        local segment
        if i < 1 then
			i = #bytes+1
        end
		-- **** SEGMENT = j+1 .. i-1
		k = findChar(bytes,44,j+2,i-1) -- ","
        local islrg  = (bytes[j] == 49) -- "1"
        local column = tonumber(string.char(table.unpack(bytes, j+2, k-1)))
        -- **** CHUNK = k+1 .. i-1
		local p = math.floor(column/6.85+.5)+1
        local lrg = ""
        for l = k+1,i-1 do
            -- Small fonts have a offset of 128(d) 0x80(hex).
            -- The asterix char (*) has been translated from 176(d) to 30(d).
            -- The box char [] has been translated to 31 (d) => translate to Yen-sign
			local c = bytes[l]
            local il = islrg
            if c < 0 then 
				c = c + 128
				il = false
            elseif c > 128 then
                c = c - 128
            else 
                il = true 
			end
            if c == 30 then
				c = 176
            elseif c == 31 or c == 10 then 
				c = 165
            end
            lrg = lrg .. (il and string.char(c) or " ")
        end
		local q = p + lrg:len() - 1
		j = i+1
		large = (p > 1 and large:sub(1,p-1) or "") .. lrg .. ((q < 30) and large:sub(q+1) or "")
    end
	large = large:gsub(string.char(176), "\194\176"):gsub(string.char(165), "\194\165")
	return large
end

function getSmallXfmcString(bytes) 
    local small = "                              "
    local i = findChar(bytes, 47) -- "/"
	if i < 1 then return "" end
	local j = i+1
	local k
	while i < #bytes do
        i = findChar(bytes,59,i+1) -- ";"
        local segment
        if i < 1 then
			i = #bytes+1
        end
		-- **** SEGMENT = j+1 .. i-1
		k = findChar(bytes,44,j+2,i-1) -- ","
        local islrg  = (bytes[j] == 49) -- "1"
        local column = tonumber(string.char(table.unpack(bytes, j+2, k-1)))
        -- **** CHUNK = k+1 .. i-1
		
        local p = math.floor(column/6.85+.5)+1
        local sml = ""
        
		for l = k+1,i-1 do
            -- Small fonts have a offset of 128(d) 0x80(hex).
            -- The asterix char (*) has been translated from 176(d) to 30(d).
            -- The box char [] has been translated to 31 (d)
            --local c = chunk:byte(i)
			local c = bytes[l]
            local d = c
            local il = islrg
            if c < 0 then 
				c = c + 128
				il = false
            elseif c > 128 then
                c = c - 128
            else 
                il = true 
			end
            if c == 30 then
				c = 176
            elseif c == 31 or c == 10 then 
				c = 165
            end
            sml = sml .. (il and " " or string.char(c))
        end
		local q = p + sml:len() - 1
		j = i+1
		small = (p > 1 and small:sub(1,p-1) or "") .. sml .. ((q < 30) and small:sub(q+1) or "")
    end
    small = small:gsub(string.char(176), "\194\176"):gsub(string.char(165), "\194\165")
    return small
end


function getBothXfmcStrings(bytes) 
    local large = "                              "
    local small = "                              "
    local i = findChar(bytes, 47) -- "/"
	if i < 1 then return {"", ""} end
	local j = i+1
	local k
	while i < #bytes do
        i = findChar(bytes,59,i+1) -- ";"
        local segment
        if i < 1 then
			i = #bytes+1
        end
		-- **** SEGMENT = j+1 .. i-1
		k = findChar(bytes,44,j+2,i-1) -- ","
        local islrg  = (bytes[j] == 49) -- "1"
        local column = tonumber(string.char(table.unpack(bytes, j+2, k-1)))
        -- **** CHUNK = k+1 .. i-1
		
        local p = math.floor(column/6.85+.5)+1
        local lrg = ""
        local sml = ""
        
		for l = k+1,i-1 do
            -- Small fonts have a offset of 128(d) 0x80(hex).
            -- The asterix char (*) has been translated from 176(d) to 30(d).
            -- The box char [] has been translated to 31 (d)
            --local c = chunk:byte(i)
			local c = bytes[l]
            local il = islarge
            if c < 0 then 
				c = c + 128
				il = false
            elseif c > 128 then
                c = c - 128
            else 
                il = true 
			end
            if c == 30 then
				c = 176
            elseif c == 31 or c == 10 then 
				c = 165
            end
            lrg = lrg .. (il and string.char(c) or " ")
            sml = sml .. (il and " " or string.char(c))
        end
		local q = p + lrg:len() - 1
		j = i+1
		large = (p > 1 and large:sub(1,p-1) or "") .. lrg .. ((q < 30) and large:sub(q+1) or "")
		small = (p > 1 and small:sub(1,p-1) or "") .. sml .. ((q < 30) and small:sub(q+1) or "")
    end
    large = large:gsub(string.char(176), "\194\176"):gsub(string.char(165), "\194\165")
    small = small:gsub(string.char(176), "\194\176"):gsub(string.char(165), "\194\165")
    return {large, small}
end

function getXfmcLineName(num)
	if     num == 1  then 
		return "xfmc/Upper"
    elseif num == 14 then 
		return "xfmc/Scratch"
    elseif num == 15 then 
		return  "xfmc/Messages"
	elseif num % 2 == 0 then  
		return "xfmc/Panel_" .. num -- need to swap lines: 2,1,4,3....
	else
		return "xfmc/Panel_" .. (num-2)
	end
end
