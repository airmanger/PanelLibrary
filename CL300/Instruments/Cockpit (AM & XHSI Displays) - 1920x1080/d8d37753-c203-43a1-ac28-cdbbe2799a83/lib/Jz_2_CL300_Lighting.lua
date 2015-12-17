-- ************************************************************************
-- ** Datarefs
-- ************************************************************************
local BUS_VOLTS_L    = XFlt("sim/cockpit2/electrical/bus_volts", 1, 6)
local BUS_VOLTS_R    = XFlt("sim/cockpit2/electrical/bus_volts", 2, 6)

BRTX_NIGHT     = XFlt("sim/graphics/scenery/percent_lights_on")
BRTX_DOME      = XFlt("cl300/dome_h")
BRTX_GLARESHLD = XFlt("cl300/gshldl_h")
BRTX_PEDESTAL  = XFlt("cl300/pedestal_h")
BRTX_DISPLAYS  = XFlt("cl300/ppfd_h")
BRTX_ANNUN     = XFlt("cl300/annun_h")

BRTX_NIGHT.silent  = true
BUS_VOLTS_L.silent = true
BUS_VOLTS_R.silent = true

ELEC_ON        = AInt("ELEC/ON")
BRT_AMBIENT    = AInt("LIGHT/AMBIENT")
BRT_GLARESHLD  = AInt("LIGHT/GLARESHLD")
BRT_PEDESTAL   = AInt("LIGHT/PEDESTAL")
BRT_DISPLAYS   = AInt("LIGHT/DISPLAYS")
BRT_ANNUN      = AInt("LIGHT/ANNUN")

-- ************************************************************************
-- ** Dataref logic
-- ************************************************************************
local ELEC_ON_LOGIC = Logic.new({BUS_VOLTS_L, BUS_VOLTS_R}, 
    function(self, valpos, newval, oldval) 
		local level = (self.values[1] > 20 or self.values[2] > 20) and 1 or 0
		if self.set ~= level then
			self.set = level
			ELEC_ON:write(level)
		end
	end)

	local BRT_AMBIENT_LOGIC = Logic.new({BRTX_NIGHT, BRTX_DOME, ELEC_ON}, 
    function(self, valpos, newval, oldval) 
		local outside = 1 + math.floor(4 * self.values[1])                  -- day:  0->1, night: 1->5
		local dome    = 5 - math.floor(3 * self.values[2] * self.values[3])	-- full: 1->2, off:   0->5 
		local level   = math.min(outside, dome)
		if self.set ~= level then
			if DEBUG then print("!!! AMBIENT := " .. level) end
			self.set = level
			BRT_AMBIENT:write(level)
		end
	end)
	
local BRT_GLARESHLD_LOGIC = Logic.new({BRT_AMBIENT, BRTX_GLARESHLD, ELEC_ON}, 
    function(self, valpos, newval, oldval) 
		local level = 0
		if self.values[1] > 1 then	
			level = math.floor(4 * (0.1 + self.values[2] * self.values[3]))
		end
		if self.set ~= level then
			if DEBUG then print("!!! GLARESHLD := " .. level) end
			self.set = level
			BRT_GLARESHLD:write(level)
		end
	end)

local BRT_PEDESTAL_LOGIC = Logic.new({BRT_AMBIENT, BRTX_PEDESTAL, ELEC_ON}, 
    function(self, valpos, newval, oldval) 
		local level = 0
		if self.values[1] > 1 then	
			level = math.floor(4 * (0.1 + self.values[2] * self.values[3]))
		end
		if self.set ~= level then
			if DEBUG then print("!!! PEDESTAL := " .. level) end
			self.set = level
			BRT_PEDESTAL:write(level)
		end
	end)
	
local BRT_DISPLAYS_LOGIC = Logic.new({BRTX_DISPLAYS, ELEC_ON}, 
    function(self, valpos, newval, oldval) 
		local level = 5 - math.floor(4 * (0.1 + self.values[1] * self.values[2]))
		if self.set ~= level then
			if DEBUG then print("!!! DISPLAYS := " .. level) end
			self.set = level
			BRT_DISPLAYS:write(level)
		end
	end)

local BRT_ANNUN_LOGIC = Logic.new({BRTX_ANNUN, ELEC_ON}, 
    function(self, valpos, newval, oldval) 
		local level = math.floor((1 + self.values[1]) * self.values[2])
		if self.set ~= level then
			if DEBUG then print("!!! ANNUN := " .. level) end
			self.set = level
			BRT_ANNUN:write(level)
		end
	end)

-- ************************************************************************
-- ** LightingTypes:
-- ************************************************************************
LIGHTING_GLARESHLD = LightingType.new(BRT_AMBIENT,   {"", "_75%", "_50%", "_25%", "_05%"}, 
									  BRT_GLARESHLD, {"_LIT25%", "_LIT50%", "_LIT75%", "_LIT100%"}, 
									  BRT_DISPLAYS,  {1, 0.75, 0.5, 0.25, 0} )
LIGHTING_PEDESTAL  = LightingType.new(BRT_AMBIENT, 	 {"", "_75%", "_50%", "_25%", "_05%"}, 
									  BRT_PEDESTAL,  {"_LIT25%", "_LIT50%", "_LIT75%", "_LIT100%"}, 
									  BRT_DISPLAYS,  {1, 0.75, 0.5, 0.25, 0} )

DEFAULT_LIGHTING_TYPE = LIGHTING_GLARESHLD
