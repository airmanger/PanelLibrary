-- ************************************************************************
-- ** Custom XFMC content
-- ************************************************************************
XFMC_STATUS   = XInt("xfmc/Status")
XFMC_LED_AP   = AInt("xfmc/Status_AP")
XFMC_LED_LNAV = AInt("xfmc/Status_LNAV")
XFMC_LED_VNAV = AInt("xfmc/Status_VNAV")
XFMC_LED_ATHR = AInt("xfmc/Status_ATHR")
XFMC_LED_EXEC = AInt("xfmc/Status_EXEC")

local XFMC_LED_LOGIC = Logic.new({XFMC_STATUS}, 
    function(self, valpos, newval, oldval) 
		if valpos == nil then newval = self.values[1] end
		XFMC_LED_AP:write(newval % 2)
		XFMC_LED_LNAV:write(math.floor((newval % 4)  /  2))
		XFMC_LED_VNAV:write(math.floor((newval % 8)  /  4))
		XFMC_LED_ATHR:write(math.floor((newval % 16) /  8))
		XFMC_LED_EXEC:write(math.floor((newval % 64) / 32))
	end)

XFMC_PAGE_NUM   = AInt("FMC/PAGE_NUM")

xpl_dataref_subscribe("cl300/flgtplan_show_entry", "INT", function(v) XFMC_SHOW_ENTRY = v end)

local XFMC_LINE_LABEL = 1
local XFMC_LINE_DATA  = 2
local XFMC_LINE_PAGE  = 3
local XFMC_LINE_SCRPD = 4
local XFMC_LINE_MSG   = 5

XFMC_COLOR_WHITE   = 0xFFFFFF
XFMC_COLOR_GREY    = 0xEEEEEE
XFMC_COLOR_GREEN   = 0x00FF00
XFMC_COLOR_CYAN    = 0x00DDFF
XFMC_COLOR_MAGENTA = 0xFF00DD 
XFMC_COLOR_UNDEF   = 0

FMCRow = {}
FMCRow.__index = FMCRow
function FMCRow.new(num)
	-- native xfmc dataref:
	local src
	local typ
	if     num == 1  then 
		src = "xfmc/Upper"
		typ = XFMC_LINE_PAGE
    elseif num == 14 then 
		src = "xfmc/Scratch"
		typ = XFMC_LINE_SCRPD
    elseif num == 15 then 
		src = "xfmc/Messages"
		typ = XFMC_LINE_MSG
	elseif num % 2 == 0 then  
		src = "xfmc/Panel_" .. num -- need to swap lines: 2,1,4,3....
		typ = XFMC_LINE_LABEL
	else
		src = "xfmc/Panel_" .. (num-2)
		typ = XFMC_LINE_DATA
	end
	-- object:
    local self = {
		dataref     = XByt(src,80),
        name        = src,
		linenum     = num,
		linetype    = typ,
		rownum      = math.floor(num/2), -- counting label and data as one!
		raw         = "",
		buffer      = nil,
		forceLarge  = (num == 1 or num > 13),
		txtLarge    = IStr("xfcm/Line_" .. num .. "_lg"),
		colLarge    = IInt("xfmc/Color_" .. num .. "_lg")
    }
	self.colLarge:write(num == 1 and XFMC_COLOR_CYAN or XFMC_COLOR_GREY)
	
	if not self.forceLarge then
		self.txtSmall    = IStr("xfcm/Line_" .. num .. "_sm")
		self.txtLargeAlt = IStr("xfcm/Line_" .. num .. "_lg_alt")
		self.txtSmallAlt = IStr("xfcm/Line_" .. num .. "_sm_alt")
		self.colSmall    = IInt("xfmc/Color_" .. num .. "_sm")
		self.colLargeAlt = IInt("xfmc/Color_" .. num .. "_lg_alt") 
		self.colSmallAlt = IInt("xfmc/Color_" .. num .. "_sm_alt")
		self.colSmall:write(XFMC_COLOR_CYAN)
	end
	
	self.dataref.silent = true
	setmetatable(self,FMCRow)
	
	self.dataref:subscribe(self, 1)
	
    return self
end

function FMCRow:findChar(char, start, finish)
	if start == nil then
		start = 1
	end
    if finish == nil then
        finish = #self.buffer
    end
    for i = start,finish do
		if self.buffer[i] == char then
			return i
		elseif self.buffer[i] == 0 then
			return -1
		end
	end
	return -1
end

function FMCRow:getRaw()
	local raw = ""
	if type(self.buffer) ~= "nil" then
		for i = 1,#self.buffer do
			raw = raw .. tostring(self.buffer[i]) .. ","
		end
	end
	return raw
end

function FMCRow:update(ignore, bytes)
	self.buffer = bytes
	local raw = self:getRaw()
	if raw == self.raw then return end
	self.raw = raw
	
	local large = "                              "
	local small = "                              "
    
	local i = self:findChar(47) -- "/"
	local page = -99
	if i > 0 then 
	
		page = tonumber(string.char(table.unpack(bytes, 1, i-1)));
		XFMC_PAGE_NUM:write(page)
		
		local j = i+1
		local k
		while i < #bytes do
			i = self:findChar(59,i+1) -- ";"
			local segment
			if i < 1 then
				i = #bytes+1
			end
			-- **** SEGMENT = j+1 .. i-1
			k = self:findChar(44,j+2,i-1) -- ","
			local islrg  = (bytes[j] == 49) -- "1"
			local column = tonumber(string.char(table.unpack(bytes, j+2, k-1)))
			if type(column) == "nil" then
				break
			end
			-- **** CHUNK = k+1 .. i-1
			local p = math.floor(column/6.85+.5)+1
			local lrg = ""
			local sml = ""
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
				if self.forceLarge then il = true end
				lrg = lrg .. (il and string.char(c) or " ")
				sml = sml .. (il and " " or string.char(c))
			end
			local q = p + lrg:len() - 1
			j = i+1
			large = (p > 1 and large:sub(1,p-1) or "") .. lrg .. ((q < 30) and large:sub(q+1) or "")
			small = (p > 1 and small:sub(1,p-1) or "") .. sml .. ((q < 30) and small:sub(q+1) or "")
		end
		
	end
	
	if not self.forceLarge then
		small_alt = "                              "
		large_alt = "                              "
		
		-- set defaults:
		local clg = XFMC_COLOR_GREY
		local csm = XFMC_COLOR_CYAN
		local cla = XFMC_COLOR_GREY
		local csa = XFMC_COLOR_MAGENTA
		local split = 0
		
		if page == 2 and self.rownum < 6 then -- **** LEGS ***********************
			split = 15
			clg = XFMC_COLOR_GREY
			csm = XFMC_COLOR_GREY
		elseif page == 12 then -- *** TAKEOFF ****************
			if self.linenum == 3 then
				split = 4
				clg = XFMC_COLOR_GREEN
				csm = XFMC_COLOR_MAGENTA
			elseif self.linenum == 5 or self.linenum == 7 then
				csm = XFMC_COLOR_MAGENTA
			end
		elseif page == 3 then -- *** APPROACH ****************
			if sel.rownum < 5 and sel.linetype == XFMC_LINE_DATA then
				split = 25
				cla = XFMC_COLOR_MAGENTA
			end
		end
		
		-- split lines
		if split > 0 then
			large_alt = string.rep(" ", split) .. string.sub(large, split+1)
			small_alt = string.rep(" ", split) .. string.sub(small, split+1)
			large = string.sub(large,1,split) .. string.rep(" ", 30-split)
			small = string.sub(small,1,split) .. string.rep(" ", 30-split)
		end
		-- save colors
		self.colLarge:write(clg)
		self.colSmall:write(csm)
		self.colLargeAlt:write(cla)
		self.colSmallAlt:write(csa)

		-- write to datarefs
		self.txtLarge:write(large:gsub(string.char(176), "\194\176"):gsub(string.char(165), "\194\165"))
		self.txtSmall:write(small:gsub(string.char(176), "\194\176"):gsub(string.char(165), "\194\165"))
		self.txtLargeAlt:write(large_alt:gsub(string.char(176), "\194\176"):gsub(string.char(165), "\194\165"))
		self.txtSmallAlt:write(small_alt:gsub(string.char(176), "\194\176"):gsub(string.char(165), "\194\165"))
		
	else
		-- write to datarefs
		self.txtLarge:write(large:gsub(string.char(176), "\194\176"):gsub(string.char(165), "\194\165"))
	end
	
end

XFMC_LINES = {}
for i = 1,15 do
	XFMC_LINES[i] = FMCRow.new(i)
end

