-- EMPTY: Transparent image to be used for the invisible buttons.
EMPTY = "!EMPTY.png"
DIAL  = "!DIAL.png"
-- ** Uncomment the next line to enable the red overlays to show the clickable areas:
if DEBUG then
	EMPTY = "!EMPTY_CYAN.png"
	DIAL  = "!DIAL_CYAN.png"
end

-- ALLOW_REVERSE: If this is set to true, the up/down button will move the switch in the 
-- opposite direction (down/up) if the switch is already at its end of its movement. 
ALLOW_REVERSE = false

-- CLASSIC_BUTTONS: If this is set to true, encoders and rotary switches will use the old button interface.
-- ** Uncomment the next line for 'classic' button interface:
--CLASSIC_BUTTONS = true

-- ENABLE_SOUNDS: Enables sounds, default = true
--ENABLE_SOUNDS = false

-- ************************************************************************
-- ** Linked Datarefs
-- ************************************************************************
-- Special APU-Logic so you can "hold" the APU switch and the apu start
-- is triggered via command so a sync via SmartCopilot is possible.
local APU_Switch  = AInt("int/APU_Switch")
local APU_Dataref = XInt("sim/cockpit/engine/APU_switch")
local APU_Start   = XCmd("sim/electrical/APU_start")
-- APU_Switch is our 'local' switch instance. When moved to 2, it will trigger
-- the APU_start command and will NOT be automatically moved back to 1 by the 
-- APU_Dataref.
local XPDR_LOGIC = Logic.new({APU_Dataref, APU_Switch}, 
    function(self, valpos, newval, oldval) 
        if valpos == 1 then -- XP changed
            if self.values[2] < 2 then
                self:write(2, newval)
            end
        else -- Knob Turned
            self:write(1, newval)
            if newval == 2 then
                APU_Start:invoke(1)
            end
        end
    end)


-- Hide other pages when page is opened
local PAGE_MAIN   = AInt("PAGES/MAIN_SHOW")
local PAGE_FMC    = AInt("PAGES/FMC_SHOW")
local PAGE_UPPER  = AInt("PAGES/UPPER_SHOW")
local PAGE_LOWER  = AInt("PAGES/LOWER_SHOW")
local PAGE_HELPER = AInt("PAGES/HELPER_SHOW")
local PAGE_HIDER = Logic.new({PAGE_FMC, PAGE_UPPER, PAGE_LOWER, PAGE_HELPER}, 
    function(self, valpos, newval, oldval) 
        if newval == 1 then
			for i = 1,3 do
                if i ~= valpos then self:write(i, 0) end
            end
			self:write(4,1)
		else
			self:write(4,0)
        end
    end)

-- ************************************************************************
-- ** RECTANGLES for click-able area of icons/buttons
-- ************************************************************************
CAToggleV   = Rectangle.new(  0,  0, 40, 52) -- Vertical toggle switch
CAToggleDn  = Rectangle.new(  0, 13, 40, 26)
CAToggleUp  = Rectangle.new(  0,-13, 40, 26)
CAToggleH   = Rectangle.new(  0,  0, 52, 40) -- Horizontal toggle switch
CAToggleLft = Rectangle.new(-13,  0, 26, 40)
CAToggleRgt = Rectangle.new( 13,  0, 26, 40)

CARotaryL   = Rectangle.new(-19,  0, 39, 39) -- Single large knob
CARotaryR   = Rectangle.new( 19,  0, 39, 39) 
CARotarySL  = Rectangle.new(-10,  0, 20, 30) -- Single small knob
CARotarySR  = Rectangle.new( 10,  0, 20, 30) 

CARotaryOL  = Rectangle.new(-39,  0, 39, 39) -- Dual knob, outer function
CARotaryOR  = Rectangle.new( 39,  0, 39, 39)
CARotaryID  = Rectangle.new(  0, 39, 39, 39) -- Dual knob, inner function
CARotaryIU  = Rectangle.new(  0,-39, 39, 39)
CARotaryPB  = Rectangle.new(  0,  0, 20, 20) -- Encoder pushbutton

CACoverS    = Rectangle.new(  0,-31, 54, 25) -- Covers for guarded Korrys
CACoverL    = Rectangle.new(  0,-37, 70, 25)

-- ************************************************************************
-- ** ICONS 
-- ************************************************************************
IconKey       = Icon.new(nil, nil, Rectangle.new(0,0,44,32))
IconKeyFMC    = Icon.new(nil, nil, Rectangle.new(0,0,50,50))
IconKeyAPDisc = Icon.new(nil, nil, Rectangle.new(0,0,70,32))

IconLedRnd    = Icon.new("LED_RND_<GREEN>_##", {"##", "DIM3", "DIM2", "DIM", "BRT"})
IconLedBar    = Icon.new("LED_BAR_<GREEN>_##", {"##", "DIM", "BRT"})
IconLedFMC    = Icon.new("LED_FMC_##",         {"##", "DIM", "BRT"})

IconPage     = Icon.new("##_<FMC>", {"##", "PAGE"}) 

IconLedKorryS = Icon.new("A_<ON>_##",     {"OFF",  "DIM",  "BRT"})
IconLedKorryL = Icon.new("A_<ENFIRE>_##", {"OFF",  "DIM",  "BRT"})
IconLedKorryM = Icon.new("A_<MW>_##",     {"OFF",  "DIM3", "DIM2", "DIM",  "BRT"})

IconKorryS    = Icon.new("PBA_SM_##", {"OFF", "ON"})
IconKorryL    = Icon.new("PBA_LG_##", {"OFF", "ON"})

IconCoverS    = Icon.new("COV_<CLR>_##", {"CLSD", "OPEN"}, CACoverS)
IconCoverL    = Icon.new("COV_<ENF>_##", {"CLSD", "OPEN"}, CACoverL)

IconToggleV   = Icon.new("TGL_V_##", {"D", "C", "U"}, CAToggleV, CAToggleDn,  CAToggleUp)
IconToggleH   = Icon.new("TGL_H_##", {"L", "C", "R"}, CAToggleH, CAToggleLft, CAToggleRgt)

IconSwitch    = Icon.new("SW_<CIR>", nil, nil, CARotaryL,  CARotaryR)
IconSwitchO   = Icon.new("SW_<CIR>", nil, nil, CARotaryOL, CARotaryOR)
IconVolumeL   = Icon.new("VOL_LG",   nil, nil, CARotaryL,  CARotaryR)
IconVolumeS   = Icon.new("VOL_SM",   nil, nil, CARotarySL, CARotarySR)

IconEncoderO  = Icon.new("ENC_<FN>_OUT", nil, nil, CARotaryOL, CARotaryOR)
IconEncoderI  = Icon.new("ENC_<FN>_INN", nil, Rectangle.new(0,0,23,23), CARotaryID, CARotaryIU)
IconEncoderW  = Icon.new("ENC_VS_##", {"0","1","2","3"}, Rectangle.new(0,0,40,40), Rectangle.new(0,42,32,42), Rectangle.new(0,-42,32,42))
IconEncoderPS = Icon.new("ENC_<HDG>", nil, CARotaryPB) -- single encoder pushbutton
IconEncoderPD = Icon.new("ENC_<RNG>", nil, CARotaryPB) -- dual encoder pushbutton

IconFlaps     = Icon.new("H_FLAPS_##",{"0","10","20","30"}, nil, Rectangle.new(-0,-51,66,50), Rectangle.new(0,51,66,50))
IconGust      = Icon.new("H_GUST_##", {"OFF", "ON"},        Rectangle.new(-25,0,50,167))
IconGear      = Icon.new("H_GEAR_##", {"U",    "D"},        Rectangle.new(0,0,80,80))
IconPBrake    = Icon.new("H_PARK_##", {"OFF", "ON"},        Rectangle.new(0,0,125,200))
IconManGear   = Icon.new("H_MG_##",   {"IN", "OUT"},        Rectangle.new(0,0,200, 75))
IconPitchRot  = Icon.new("H_PD_OUT",  nil, 					nil, Rectangle.new(-50,0,50,120), Rectangle.new(50,0,50,120))
IconPitchPull = Icon.new("H_PD_##",   {"IN",  "##"},        Rectangle.new(0,0,50,120))

txt_load_font("MonoFMC.ttf")
txt_load_font("MonoFMCSmall.ttf")
FmcLineLg = SegmentType.new(TextField.new("MonoFMC",      24, "CENTER",  0xEEEEEE,  440, 27))
FmcLineSm = SegmentType.new(TextField.new("MonoFMCSmall", 24, "CENTER",  0x00DDFF,  440, 27))

-- ************************************************************************
-- ** SOUNDS 
-- ************************************************************************
SKey = sound_add("SOUND_KEY.wav")
SEnc = sound_add("SOUND_ENCODER.wav")
SPBA = sound_add("SOUND_PBA.wav")
SCov = sound_add("SOUND_COVER.wav")
STgl = sound_add("SOUND_TOGGLE.wav")
SLrg = sound_add("SOUND_LOUD.wav")

-- ************************************************************************
-- ** CONTROLS 
-- ************************************************************************
C300Key        = KeyType.new(IconKey,    {sound = SKey})
C300KeyFMC     = KeyType.new(IconKeyFMC, {sound = SKey})
C300LedRnd     = LEDType.new(IconLedRnd, {threshold = {.15,.40,.65,.90}})
C300LedBar     = LEDType.new(IconLedBar, {threshold = {{.1,.1},{1,2}}, keyword = "GREEN"})
C300LedFMC     = LEDType.new(IconLedFMC, {threshold = {{1,1},{1,2}}})

C300Page       = SwitchType.new(IconPage, {sound = SPBA})

C300ToggleV    = SwitchType.new(IconToggleV, {maxval = 2, sound = STgl})
C300ToggleH    = SwitchType.new(IconToggleH, {maxval = 2, sound = STgl})
C300ToggleVM   = SwitchType.new(IconToggleV, {minval = -1, momentary =  {[-1] = 0, [1] = 0}, sound = STgl})
C300ToggleHM   = SwitchType.new(IconToggleH, {minval = -1, momentary =  {[-1] = 0, [1] = 0}, sound = STgl})

C300Switch45   = SwitchType.new(IconSwitch,   {angle = 45,    maxval = 2, keyword = "ARR", dial = false, sound = SPBA})
C300Switch30   = SwitchType.new(IconSwitch,   {angle = 30,    maxval = 2, keyword = "CIR", dial = false, sound = SPBA})
C300Outer      = SwitchType.new(IconSwitchO,  {angle = 30,    maxval = 2, keyword = "CIR", dial = false, sound = SPBA})
C300VolL       = SwitchType.new(IconVolumeL,  {angle = 13.5,              step = -.05, dial = true, interval = 100 })
C300VolS       = SwitchType.new(IconVolumeS,  {angle = 13.5,              step = -.05, dial = true, interval = 100 })
C300Bright     = SwitchType.new(IconSwitch,   {angle = 19.25, minval =.3, step =  .05, dial = true, interval = 100, keyword = "CIR"})
C300Temp       = SwitchType.new(IconSwitch,   {angle = 13.5,  minval =-1, step =  .1,  dial = true, interval = 100, keyword = "CIR"})

C300EncoderO   = EncoderType.new(IconEncoderO,   {angle = 12, maxval = 30, cycle = true, interval = 100, sound = SEnc})
C300EncoderI   = EncoderType.new(IconEncoderI,   {angle = 12, maxval = 30, cycle = true, interval = 100, sound = SEnc})
C300EncoderW   = EncoderType.new(IconEncoderW,   {angle = 12, maxval = 4,  cycle = true, interval = 100, sound = SEnc})
C300EncoderPS  = KeyType.new(IconEncoderPS, {sound = SKey})
C300EncoderPD  = KeyType.new(IconEncoderPD, {sound = SKey})

C300PitchDisc = SwitchType.new(IconPitchRot, {angle = 45, minval = -1, dial = false, sound = SLrg})
C300PitchPull = GuardType.new(IconPitchPull, {closepos = 0, sound = SLrg}) 

-- PBAs
C300PBAL       = PBAType.new(IconKorryL, LEDType.new(IconLedKorryL, {threshold = {.15,.75}}), {sound = SPBA})
C300PBAS       = PBAType.new(IconKorryS, LEDType.new(IconLedKorryS, {threshold = {.15,.75}}), {sound = SPBA})
C300PBAM       = PBAType.new(IconKorryL, LEDType.new(IconLedKorryM, {threshold = {.15,.40,.65,.90}}), {sound = SPBA})
C300CoverS     = GuardType.new(IconCoverS, {sound = SCov})
C300CoverL     = GuardType.new(IconCoverL, {sound = SCov})

-- ************************************************************************
-- ** HELPERS
-- ************************************************************************
local PANEL
-- custom function to simplify PBA creation:

-- ###### PBAs  #########################################################################################
function addPbaS(x, y, dataref, key, opts)
    local refbase = string.sub(dataref.name, 0, string.len(dataref.name)-2) -- truncate "_h"-Postfix
    local refs = {dataref, XFlt(refbase)}
    local aopt = {opts, {keyword = key}}
    PANEL:add(x,y, C300PBAS:createInstance(refs, aopt))
end

function addPbaD(x, y, dataref, key, opts, key2, postfix2)
    local refbase = string.sub(dataref.name, 0, string.len(dataref.name)-2) -- truncate "_h"-Postfix
    local refs = {dataref, XFlt(refbase), XFlt(refbase .. postfix2)}
    local aopt = {opts, {keyword = key}, {keyword = key2}}
    PANEL:add(x,y, C300PBAS:createInstance(refs, aopt))
end

function addPbaC(x, y, dataref, cmd, key, opts)
    if opts == nil then opts = {momentary = {0}} else opts.momentary = {0} end
    local refs = {cmd, dataref}
    local aopt = {opts, {keyword = key}}
    PANEL:add(x,y, C300PBAS:createInstance(refs, aopt))
end

function addCPbS(x, y, dataref, key, cov, opts)
    local pbat = C300PBAS
    local covt = C300CoverS
    local refbase = string.sub(dataref.name, 0, string.len(dataref.name)-2) -- truncate "_h"-Postfix
    local refs = {dataref, XFlt(refbase)}
    local aopt = {opts, {keyword = key}}
    PANEL:add(x,y, pbat:createInstance(refs, aopt))
    PANEL:add(x,y, covt:createInstance(DataRef.new(KIND_XP, refbase .. "_cov", dataref.datatype), PANEL:last(), {keyword = cov}))
end

function addCPbL(x, y, dataref, key, cov, opts)
    local pbat = C300PBAL
    local covt = C300CoverL
    local refbase = string.sub(dataref.name, 0, string.len(dataref.name)-2) -- truncate "_h"-Postfix
    local refs = {dataref, XFlt(refbase)}
    local aopt = {opts, {keyword = key}}
    
    PANEL:add(x,y, pbat:createInstance(refs, aopt))
    PANEL:add(x,y, covt:createInstance(DataRef.new(KIND_XP, refbase .. "_cov", dataref.datatype), PANEL:last(), {keyword = cov}))
end

-- ###### Switches #########################################################################################
function addSw45(x, y, dataref, key, opts)
    if opts ~= nil then opts.keyword = key else opts = {keyword = key} end
    PANEL:add(x,y, C300Switch45:createInstance(dataref, opts))
end

function addSw30(x, y, dataref, key, opts)
    if opts ~= nil then opts.keyword = key else opts = {keyword = key} end
    PANEL:add(x,y, C300Switch30:createInstance(dataref, opts))
end

function addTglS(x, y, dataref, vert, mom, opts)
    local tp 
    if vert then
        tp = (mom and C300ToggleVM or C300ToggleV)
    else
        tp = (mom and C300ToggleHM or C300ToggleH)
    end
    PANEL:add(x,y, tp:createInstance(dataref, opts))
end

-- ###### Keys #########################################################################################
function addKeyP(x, y, ref, opts) -- permanent key
    PANEL:add(x,y, C300Key:createInstance(ref, opts))
end

function addKeyM(x, y, ref, opts) -- momentary key
    if opts ~= nil then opts.momentary = {0} else opts = {momentary = {0}} end
    PANEL:add(x,y, C300Key:createInstance(ref, opts))
end

function addKeyC(x, y, ref, maxv, opts) -- cycling key
    if opts == nil then opts = {} end
    opts.maxval = maxv
    opts.cycle  = true
    if opts.minval == nil then opts.minval = 0 end
    if opts.step   == nil then opts.step   = 1 end
    PANEL:add(x,y, C300Key:createInstance(ref, opts))
end

function addKeyX(x, y, ref, val, opts) -- fixed value key
    if opts == nil then opts = {} end
    opts.minval = val
    opts.maxval = val
    PANEL:add(x,y, C300Key:createInstance(ref, opts))
end

function addKeyF(x, y, ref, val, opts) -- fixed value fmc key
    if opts == nil then opts = {} end
    opts.minval = val
    opts.maxval = val
    PANEL:add(x,y, C300KeyFMC:createInstance(ref, opts))
end

-- ###### Rheostats #########################################################################################
function addRVol(x, y, ref, lg)
    local vt = (lg and C300VolL or C300VolS)
    PANEL:add(x,y, vt:createInstance(ref))
end

function addRTmp(x, y, ref, key)
    local opt = (key ~= nil and {keyword = key} or nil)
    PANEL:add(x,y, C300Temp:createInstance(ref), opt)
end

function addRBrt(x, y, ref, key)
    local opt = (key ~= nil and {keyword = key} or nil)
    PANEL:add(x,y, C300Bright:createInstance(ref), opt)
end

-- ###### Encoders #########################################################################################
function addEncS(x, y, rotateCmd, pushCmd, knobKey, btnKey, optO, optP)
    if optO == nil then optO = {keyword = knobKey} else optO.keyword = knobKey end
    if optP == nil then optP = {keyword = btnKey}  else optP.keyword = btnKey  end
    optP.momentary = {0}
    PANEL:add(x, y, C300EncoderO:createInstance(rotateCmd, optO))
    PANEL:add(x, y, C300EncoderPS:createInstance(pushCmd, optP))
end

function addEncD(x, y, rotateOCmd, rotateICmd, pushCmd, knobKey, btnKey, optO, optI, optP)
    if optO == nil then optO = {keyword = knobKey} else optO.keyword = knobKey end
    if optI == nil then optI = {keyword = knobKey} else optI.keyword = knobKey end
    if optP == nil then optP = {keyword = btnKey}  else optP.keyword = btnKey  end
    optP.momentary = {0}
    PANEL:add(x, y, C300EncoderO:createInstance(rotateOCmd, optO))
    PANEL:add(x, y, C300EncoderI:createInstance(rotateICmd, optI))
    PANEL:add(x, y, C300EncoderPD:createInstance(pushCmd, optP))
end

-- ###### FMC #########################################################################################
function fmcLineUpdateCallback(inst)
	inst:setColor(inst.values[2])
	inst:setText(inst.values[1])
end

function addFmcLine(x, y, linenum)
	-- datarefs
	local xl = XFMC_LINES[linenum]
	-- create lines
	PANEL:add(x, y, FmcLineLg:createInstance({xl.txtLarge, xl.colLarge}, {updateCallback = fmcLineUpdateCallback}))
	if not xl.forceLarge then
		PANEL:add(x, y, FmcLineSm:createInstance({xl.txtSmall,    xl.colSmall},    {updateCallback = fmcLineUpdateCallback}))
		PANEL:add(x, y, FmcLineLg:createInstance({xl.txtLargeAlt, xl.colLargeAlt}, {updateCallback = fmcLineUpdateCallback}))
		PANEL:add(x, y, FmcLineSm:createInstance({xl.txtSmallAlt, xl.colSmallAlt}, {updateCallback = fmcLineUpdateCallback}))
	end
end

-- ###### Other Elements #########################################################################################
function addElem(x, y, ref, et, opt) 
    PANEL:add(x,y, et:createInstance(ref, opt))
end    

-- ************************************************************************
-- ** PANEL TYPES
-- ************************************************************************
local PD = PanelType.new("BASE_%%", 1)
--local PZ = PanelType.new("BASE %%", 1):addZoomedPane(2,true)

-- ************************************************************************
-- ** PAGES
-- ************************************************************************
img_add_fullscreen()

local MAIN   = Page.new("MAIN",   "BG",   nil, nil)
local FMC    = Page.new("FMC",    "PAGE_GREY", nil, Rectangle.new(1152, 152, 768, 888))
local UPPER  = Page.new("UPPER",  "PAGE_GREY", nil, Rectangle.new(1152, 152, 768, 888))
local LOWER  = Page.new("LOWER",  "PAGE_GREY", nil, Rectangle.new(1152, 152, 768, 888))
local HELPER = Page.new("HELPER", "PAGE_GREY", nil, Rectangle.new(1147, 152,   5, 588))

-- ************************************************************************
-- ** MAIN
-- ************************************************************************
PANEL = PD:createInstance(MAIN, "BARO", 0, 0)
addEncS( 76, 84, XCmd("sim/instruments/barometer_up", "sim/instruments/barometer_down"), XCmd("sim/instruments/barometer_2992"), "RG", "BARO")
addPbaS(148, 84, XInt("cl300/comps_head_l_h"),  "DG")
addTglS(220, 84, XInt("cl300/comps_slew_l_sw"), false, true)
addTglS(292, 84, XInt("cl300/rudd_ped_l_sw"),   true,  true)

local mast_caut = XFlt("cl300/mast_caut")
local mast_warn = XFlt("cl300/mast_warn")
mast_caut.silent = true -- disable value change logging
mast_warn.silten = true -- disable value change logging
PANEL = PD:createInstance(MAIN, "WARN", 368, 0)
addElem(50, 76, {CLEAR_ALERTS, mast_caut, mast_warn}, C300PBAM,
                {{momentary = {0}}, {keyword = "MC"}, {keyword = "MW"}})

PANEL = PD:createInstance(MAIN, "DCP", 468, 0)
addEncD( 64, 108, XCmd("xap/DCP/dcp_tune_right_coarse", "xap/DCP/dcp_tune_left_coarse"), 
                  XCmd("xap/DCP/dcp_tune_right_fine", "xap/DCP/dcp_tune_left_fine"), 
                  XCmd("xap/DCP/dcp_tune_stb"), "FN", "TUNE", {angle = 36}, {angle = 36})

addEncD(304, 108, XCmd("xap/DCP/dcp_menu_right", "xap/DCP/dcp_menu_left"), 
                  XCmd("xap/DCP/dcp_data_right", "xap/DCP/dcp_data_left"), 
                  XCmd("xap/DCP/dcp_data_sel"), "RG", "MENU", {angle = 36}, {angle = 36})

addEncD(544, 108, XInt("cl300/dcp_tilt"), XInt("cl300/dcp_range"), XInt("sim/cockpit2/EFIS/map_range"), "RG", "MENU",
                  {angle = 30, maxval = 1500, minval = -1500}, {angle = 30, maxval = 1500, minval = -1500}, {maxval = 2, minval = 2})

addKeyP( 64,  44, XInt("cl300/dcp_1_2"))
addKeyP(144,  44, XInt("cl300/dcp_dmeh"))
addKeyP(144, 108, XInt("cl300/mfd_sel_state"))
addKeyC(224,  44, XInt("cl300/dcp_navsrc"),    3)
addKeyX(224, 108, XInt("cl300/autop_brgsrc"),  0)
addKeyC(384,  44, XInt("sim/cockpit2/EFIS/map_mode"), 5)
addKeyP(384, 108, XCmd("cl300/DCP/dcp_refs_button"))
addKeyP(464,  44, XInt("sim/cockpit2/EFIS/EFIS_tcas_on"))
addKeyP(464, 108, XInt("cl300/dcp_radar"))
addKeyP(544,  44, XInt("sim/cockpit2/EFIS/EFIS_weather_on"))

PANEL = PD:createInstance(MAIN, "MCP", 1076, 0)
addEncS( 60, 108, CRS_DIAL, XInt("cl300/crc_butt"),  "FN", "CRS", {tics = 30})
addEncS(220, 108, HDG_DIAL, XInt("cl300/fgp_s_hdg"), "RG", "HDG", {tics = 30})
addEncS(380, 108, SPD_DIAL, XCmd("sim/autopilot/knots_mach_toggle"), "FN", "SPD", {tics = 20})
addEncS(620, 108, ALT_DIAL, CANCEL_ALT_ALERT, "FN", "ALT", {tics = 20})
addElem(528,  76, VS_WHEEL, C300EncoderW)

addKeyP( 60,  44, XInt("cl300/autop_fdir_h"))
addKeyP(140,  44, XInt("cl300/autop_nav_h"))
addKeyP(140, 108, XInt("cl300/half_bank_h"))
addKeyP(220,  44, XInt("cl300/autop_hdg_h"))
addKeyP(300,  44, XInt("cl300/autop_appr_h"))
addKeyP(300, 108, XInt("cl300/autop_bc_h"))
addKeyP(380,  44, XInt("cl300/autop_flc_h"))
addKeyP(460,  44, XInt("cl300/autop_vs_h"))
addKeyP(460, 108, XInt("cl300/autop_vnav_h"))
addKeyP(620,  44, XInt("cl300/autop_alt_h"))
addKeyP(700,  44, XInt("cl300/autop_ap_h"))
addKeyP(700, 108, XInt("cl300/autop_xfr_h"))
addKeyP(780,  44, XInt("cl300/autop_yd_h"))
addKeyM(780, 108, XCmd("sim/autopilot/servos_fdir_yawd_off"), {icon = IconKeyAPDisc})

PANEL = PD:createInstance(MAIN, "MFD", 0, 976)
addTglS(596, 53, XInt("cl300/mfdpan_lr_sw"), false, false, {maxval=1})
addKeyM( 72, 28, XCmd("cl300/mfd_frmt"))
addKeyM( 72, 76, XCmd("cl300/mfd_aice"))
addKeyM(120, 28, XCmd("cl300/mfd_tfc"))
addKeyM(120, 76, XCmd("cl300/mfd_ecs"))
addKeyM(168, 28, XCmd("cl300/mfd_trwx"))
addKeyM(168, 76, XCmd("cl300/mfd_elec"))
addKeyM(216, 76, XCmd("cl300/mfd_flt"))
addKeyM(240, 28, XCmd("cl300/mfd_cas"))
addKeyM(264, 76, XCmd("cl300/mfd_fuel"))
addKeyM(312, 28, XCmd("cl300/mfd_sumry"))
addKeyM(312, 76, XCmd("cl300/mfd_hyd"))
addKeyM(372, 76, XCmd("cl300/mfd_cklst"))
addKeyM(396, 28, XCmd("cl300/chklist_enter"))
addKeyM(420, 76, XCmd("cl300/chklist_skip"))
addKeyM(477, 52, XCmd("cl300/chklist_jleft"))
addKeyM(516, 52, XCmd("cl300/chklist_jright"))

PANEL = PD:createInstance(MAIN, "TAWS", 668, 976)
addCPbS( 56, 64, XInt("cl300/taws_gs_h"),  "OFF","CLR")
addCPbS(128, 64, XInt("cl300/taws_flp_h"), "OFF","CLR")
addCPbS(200, 64, XInt("cl300/taws_ter_h"), "OFF","CLR")

PANEL = PD:createInstance(MAIN, "GEAR", 924, 976)
addPbaS( 56, 64, XInt("cl300/nws_h"), "OFF")
addElem(124, 60, XInt("sim/cockpit2/controls/gear_handle_down"), SwitchType.new(IconGear, {sound = SLrg}))

PANEL = PD:createInstance(MAIN, "STBY", 1147, 239)
addKeyX(11,   67, XInt("cl300/stby_ins_dim_brt"), 1)
addKeyX(11,  127, XInt("cl300/stby_ins_dim_brt"), 0)
addKeyX(147,  11, XFlt("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_copilot"), 29.92)
addElem(173, 173, XFlt("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_copilot"), 
                  EncoderType.new(IconEncoderI, {keyword = "RG", angle = 15, minval = 29.5, maxval = 30.5, step  = .01, cycle = false, interval = 25,  tics = 50, sound = SEnc}))

PANEL = PD:createInstance(MAIN, "CLK", 1147, 439)
addKeyP( 11,  47, XInt("cl300/clock_flt"))
addKeyP(183,  47, XInt("cl300/clock_gps"))
addKeyC( 11, 147, XInt("cl300/clock_timer_h"), 3)
addKeyC(183, 147, XInt("cl300/clock_mode"), 3)

PANEL = PD:createInstance(MAIN, "PAGES", 1171, 1047)
addElem(117, 16, PAGE_FMC,   C300Page, {keyword = "FMC"})
addElem(365, 16, PAGE_UPPER, C300Page, {keyword = "UPPER"})
addElem(613, 16, PAGE_LOWER, C300Page, {keyword = "LOWER"})

-- ************************************************************************
-- ** FMC
-- ************************************************************************
DEFAULT_LIGHTING_TYPE = LIGHTING_PEDESTAL

PANEL = PD:createInstance(FMC, "FMC", 16, 16)

addFmcLine(368,  74, 1)
addFmcLine(368, 108, 2)
addFmcLine(368, 132, 3)
addFmcLine(368, 160, 4)
addFmcLine(368, 184, 5)
addFmcLine(368, 212, 6)
addFmcLine(368, 236, 7)
addFmcLine(368, 264, 8)
addFmcLine(368, 288, 9)
addFmcLine(368, 316, 10)
addFmcLine(368, 340, 11)
addFmcLine(368, 368, 12)
addFmcLine(368, 392, 13)
addFmcLine(368, 426, 14)

addElem( 80, 452, {XFMC_LED_AP,   BRT_ANNUN}, C300LedFMC)
addElem(656, 452, {XFMC_LED_EXEC, BRT_ANNUN}, C300LedFMC)

addKeyF( 80, 134, XInt("xfmc/Keypath_entry"),  0)
addKeyF( 80, 186, XInt("xfmc/Keypath_entry"),  1)
addKeyF( 80, 238, XInt("xfmc/Keypath_entry"),  2)
addKeyF( 80, 290, XInt("xfmc/Keypath_entry"),  3)
addKeyF( 80, 342, XInt("xfmc/Keypath_entry"),  4)
addKeyF( 80, 394, XInt("xfmc/Keypath_entry"),  5)
addKeyF(656, 134, XInt("xfmc/Keypath_entry"),  6)
addKeyF(656, 186, XInt("xfmc/Keypath_entry"),  7)
addKeyF(656, 238, XInt("xfmc/Keypath_entry"),  8)
addKeyF(656, 290, XInt("xfmc/Keypath_entry"),  9)
addKeyF(656, 342, XInt("xfmc/Keypath_entry"), 10)
addKeyF(656, 394, XInt("xfmc/Keypath_entry"), 11)

addKeyF( 80, 488, XInt("xfmc/Keypath_entry"), 15) -- AP
addKeyF(152, 488, XInt("xfmc/Keypath_entry"), 13) -- RTE
addKeyF(224, 488, XInt("xfmc/Keypath_entry"), 18) -- LEGS
addKeyF(296, 488, XInt("xfmc/Keypath_entry"), 14) -- DEP/ARR
addKeyF(368, 488, XInt("xfmc/Keypath_entry"), 19) -- HOLD
addKeyF(440, 488, XInt("xfmc/Keypath_entry"), 16) -- VNAV
addKeyF(512, 488, XInt("xfmc/Keypath_entry"), 20) -- PERF
addKeyF(584, 488, XInt("xfmc/Keypath_entry"), 21) -- PROG
addKeyF(656, 488, XInt("xfmc/Keypath_entry"), 22) -- EXEC


addKeyF( 80, 552, XInt("xfmc/Keypath_entry"), 12) -- INIT REF
addKeyF(152, 552, XInt("xfmc/Keypath_entry"), 24) -- TUNE
addKeyF(224, 552, XInt("xfmc/Keypath_entry"), 23) -- MENU
addKeyM(296, 552, XCmd("cl300/flgtplan_show_prev"), {icon = IconKeyFMC}) -- PREV WAYP
addKeyM(368, 552, XCmd("cl300/flgtplan_show_next"), {icon = IconKeyFMC}) -- NEXT WAYP
addKeyF(440, 552, XInt("xfmc/Keypath_entry"), 25) -- PREV
addKeyF(512, 552, XInt("xfmc/Keypath_entry"), 26) -- NEXT
addKeyF(584, 552, XInt("xfmc/Keypath_entry"), 56) -- CLR
addKeyF(656, 552, XInt("xfmc/Keypath_entry"), 54) -- DEL

addKeyF( 80, 624, XInt("xfmc/Keypath_entry"), 27) -- A
addKeyF(140, 624, XInt("xfmc/Keypath_entry"), 28)
addKeyF(200, 624, XInt("xfmc/Keypath_entry"), 29)
addKeyF(260, 624, XInt("xfmc/Keypath_entry"), 30)
addKeyF(320, 624, XInt("xfmc/Keypath_entry"), 31)
addKeyF(380, 624, XInt("xfmc/Keypath_entry"), 32)
addKeyF(440, 624, XInt("xfmc/Keypath_entry"), 33) -- G
addKeyF(512, 624, XInt("xfmc/Keypath_entry"), 57) -- 1
addKeyF(584, 624, XInt("xfmc/Keypath_entry"), 58)
addKeyF(656, 624, XInt("xfmc/Keypath_entry"), 59) -- 3

addKeyF( 80, 684, XInt("xfmc/Keypath_entry"), 34) -- H
addKeyF(140, 684, XInt("xfmc/Keypath_entry"), 35)
addKeyF(200, 684, XInt("xfmc/Keypath_entry"), 36)
addKeyF(260, 684, XInt("xfmc/Keypath_entry"), 37)
addKeyF(320, 684, XInt("xfmc/Keypath_entry"), 38)
addKeyF(380, 684, XInt("xfmc/Keypath_entry"), 39)
addKeyF(440, 684, XInt("xfmc/Keypath_entry"), 40) -- N
addKeyF(512, 684, XInt("xfmc/Keypath_entry"), 60) -- 4
addKeyF(584, 684, XInt("xfmc/Keypath_entry"), 61)
addKeyF(656, 684, XInt("xfmc/Keypath_entry"), 62) -- 6

addKeyF( 80, 744, XInt("xfmc/Keypath_entry"), 41) -- O
addKeyF(140, 744, XInt("xfmc/Keypath_entry"), 42)
addKeyF(200, 744, XInt("xfmc/Keypath_entry"), 43)
addKeyF(260, 744, XInt("xfmc/Keypath_entry"), 44)
addKeyF(320, 744, XInt("xfmc/Keypath_entry"), 45)
addKeyF(380, 744, XInt("xfmc/Keypath_entry"), 46)
addKeyF(440, 744, XInt("xfmc/Keypath_entry"), 47) -- U
addKeyF(512, 744, XInt("xfmc/Keypath_entry"), 63) -- 7
addKeyF(584, 744, XInt("xfmc/Keypath_entry"), 64)
addKeyF(656, 744, XInt("xfmc/Keypath_entry"), 65) -- 9

addKeyF( 80, 804, XInt("xfmc/Keypath_entry"), 48) -- V
addKeyF(140, 804, XInt("xfmc/Keypath_entry"), 49)
addKeyF(200, 804, XInt("xfmc/Keypath_entry"), 50)
addKeyF(260, 804, XInt("xfmc/Keypath_entry"), 51)
addKeyF(320, 804, XInt("xfmc/Keypath_entry"), 52) -- Z
addKeyF(440, 804, XInt("xfmc/Keypath_entry"), 55) -- /
addKeyF(512, 804, XInt("xfmc/Keypath_entry"), 66) -- .
addKeyF(584, 804, XInt("xfmc/Keypath_entry"), 67) -- 0
addKeyF(656, 804, XInt("xfmc/Keypath_entry"), 68) -- +/-

-- ************************************************************************
-- ** UPPER
-- ************************************************************************
PANEL = PD:createInstance(UPPER, "FUEL", 16, 16)
addPbaS(184,  60, XInt("cl300/fuel_xflow_up_h"), "BAR")
addPbaS(184, 136, XInt("cl300/fuel_xflow_dn_h"), "BAR")
addSw45( 76, 144, XInt("cl300/fuel_xpump_l"))
addSw45(292, 144, XInt("cl300/fuel_xpump_r"))

PANEL = PD:createInstance(UPPER, "AUDIO", 16, 192) 
addElem( 64,  28, {XFlt("cl300/aud_com1_l"), BRT_ANNUN}, C300LedBar)
addElem(104,  28, {XFlt("cl300/aud_com2_l"), BRT_ANNUN}, C300LedBar)
addElem(144,  28, {XFlt("cl300/aud_com3_l"), BRT_ANNUN}, C300LedBar)
addElem(184,  28, {XFlt("cl300/aud_hf1_l"),  BRT_ANNUN}, C300LedBar)
addElem(224,  28, {XFlt("cl300/aud_hf2_l"),  BRT_ANNUN}, C300LedBar)
addElem(264,  28, {XFlt("cl300/aud_cab_l"),  BRT_ANNUN}, C300LedBar)
addElem(304,  28, {XFlt("cl300/aud_pa_l"),   BRT_ANNUN}, C300LedBar)

addKeyP( 64,  48, XInt("cl300/aud_com1_l_h"))
addKeyP(104,  48, XInt("cl300/aud_com2_l_h"))
addKeyP(144,  48, XInt("cl300/aud_com3_l_h"))
addKeyP(184,  48, XInt("cl300/aud_hf1_l_h"))
addKeyP(224,  48, XInt("cl300/aud_hf2_l_h"))
addKeyP(264,  48, XInt("cl300/aud_cab_l_h"))
addKeyP(304,  48, XInt("cl300/aud_pa_l_h"))

addRVol( 64,  88, XFlt("cl300/aud_vol_1_l"))
addRVol(104,  88, XFlt("cl300/aud_vol_2_l"))
addRVol(144,  88, XFlt("cl300/aud_vol_3_l"))
addRVol(184,  88, XFlt("cl300/aud_vol_4_l"))
addRVol(224,  88, XFlt("cl300/aud_vol_5_l"))
addRVol(264,  88, XFlt("cl300/aud_vol_6_l"))
addRVol(304,  88, XFlt("cl300/aud_vol_7_l"))
addRVol( 64, 128, XFlt("cl300/aud_vol_8_l"))
addRVol(104, 128, XFlt("cl300/aud_vol_9_l"))
addRVol(144, 128, XFlt("cl300/aud_vol_10_l"))
addRVol(184, 128, XFlt("cl300/aud_vol_11_l"))
addRVol(224, 128, XFlt("cl300/aud_vol_12_l"))
addRVol(264, 128, XFlt("cl300/aud_vol_13_l"))
addRVol(304, 128, XFlt("cl300/aud_vol_14_l"))
addRVol( 64, 168, XFlt("cl300/aud_vol_15_l"))
addRVol(104, 168, XFlt("cl300/aud_vol_16_l"))
addRVol(284, 168, XFlt("cl300/aud_vol_17_l"), true)

addTglS(144, 168, XInt("cl300/aud_voice_l_sw"), true, false)
addTglS(184, 168, XInt("cl300/aud_emer_l_sw"),  true, false, {maxval=1})
addTglS(224, 168, XInt("cl300/aud_o2m_l_sw"),   true, false,  {maxval=1})

PANEL = PD:createInstance(UPPER, "INT", 16, 392)
addSw45( 76,  60,  BRTX_ANNUN,     nil, {angle = 60, maxval=1, center=.5})
addRBrt(184,  60, {BRTX_DISPLAYS,  XFlt("cl300/pmfd_h"), XFlt("cl300/cmfd_h"), XFlt("cl300/cpfd_h")})
addRBrt(292,  60, {BRTX_GLARESHLD, XFlt("cl300/gshldr_h")})
addRBrt( 76, 136,  BRTX_DOME)
addRBrt(184, 136,  BRTX_PEDESTAL)
addRBrt(292, 136,  XFlt("cl300/cbp_h"))


PANEL = PD:createInstance(UPPER, "EXT", 16, 568)
addTglS( 76,  60, XFlt("cl300/wing_insp_h"),     true, false, {maxval=1})
addTglS(148,  60, XFlt("cl300/nav_h"),           true, false)
addTglS(220,  60, XFlt("cl300/strobe_h"),        true, false)
addTglS(292,  60, XInt("cl300/smokebelts_h"),    true, false)
addTglS( 76, 136, XFlt("cl300/emeright_h"),      true, false)
addTglS(148, 136, XFlt("cl300/landlight1_h"),    true, false, {maxval=1})
addTglS(220, 136, XFlt("cl300/xap_taxilight_h"), true, false)
addTglS(292, 136, XFlt("cl300/landlight2_h"),    true, false, {maxval=1})

PANEL = PD:createInstance(UPPER, "DISPL", 16, 744)
addSw30( 68,  56, XInt("cl300/rev_pan_l"))
addSw30(184,  56, XInt("cl300/rev_tune"), nil, {maxval=3,center=2})
addSw30(300,  56, XInt("cl300/rev_pan_r"))
addSw30(124, 112, XInt("cl300/rev_att_hd"))
addSw30(228, 112, XInt("cl300/rev_air_dat"))

PANEL = PD:createInstance(UPPER, "PRESS", 384, 16)
addRTmp( 76,  60, XFlt("cl300/pressure_manrate"),     "ARR")
addPbaS(184,  60, XInt("cl300/pressure_man_h"),       "ON")
addCPbS( 76, 136, XInt("cl300/pressure_emer_depr_h"), "ON", "RED")
addCPbS(184, 136, XInt("cl300/pressure_ditch_h"),     "ON", "RED")
addElem(292, 116, XInt("cl300/pressure_lndg_alt_1"),  C300Outer, {keyword = "OUT"})
addElem(292, 116, XFlt("cl300/pressure_lndg_alt_2"), 
                  EncoderType.new(IconEncoderI, {keyword = "RG", angle = 15, minval = -1, step  = .01, cycle = false, interval = 25,  tics = 50, sound = SEnc}))

PANEL = PD:createInstance(UPPER, "AC", 384, 192)
addRTmp( 76,  60, XFlt("cl300/aircond_cockpit_temp"))
addRTmp(292,  60, XFlt("cl300/aircond_cabin_temp"))
addPbaS(184,  60, XInt("cl300/aircond_man_temp_h"), "ON")
addCPbS( 76, 136, XInt("cl300/aircond_ramair_h"),   "ON", "CLR")
addSw45(184, 144, XInt("cl300/aircond_airsource"),  nil, {maxval=3,center=1})
addPbaS(292, 136, XInt("cl300/bleed_apu_h"),        "ON")
addPbaS( 76, 212, XInt("cl300/bleed_en_l_h"),       "OFF")
addPbaS(184, 212, XInt("cl300/bleed_xbleed_h"),     "BAR")
addPbaS(292, 212, XInt("cl300/bleed_en_r_h"),       "OFF")

PANEL = PD:createInstance(UPPER, "ICE", 384, 444)
addSw45( 76,  68, XInt("cl300/antice_wngsource_r"))
addPbaS(148,  60, XInt("cl300/antice_wing_h"),    "ON")
addPbaS(220,  60, XInt("cl300/antice_probe_l_h"), "OFF")
addPbaS(292,  60, XInt("cl300/antice_probe_r_h"), "OFF")
addPbaS( 76, 136, XInt("cl300/antice_engn_l_h"),  "ON")
addPbaS(148, 136, XInt("cl300/antice_engn_r_h"),  "ON")
addPbaS(220, 136, XInt("cl300/antice_wshld_l_h"), "OFF")
addPbaS(292, 136, XInt("cl300/antice_wshld_r_h"), "OFF")

PANEL = PD:createInstance(UPPER, "ELEC", 384, 620)
addPbaS( 96,  60, XInt("cl300/left_bat_h"),    "OFF")
addPbaD(184,  60, XInt("cl300/electr_extp_h"), "ON", nil, "AVAIL", "_avail")
addPbaS(272,  60, XInt("cl300/right_bat_h"),   "OFF")
addPbaS( 48, 102, XInt("cl300/electr_stbi_h"), "OFF")
addPbaC(184, 144, XFlt("cl300/bus_tie"),        XCmd("xap/bus_tie_h_button"),  "BAR")
addPbaC( 96, 228, XFlt("cl300/electr_gen_l"),   XCmd("xap/elec_gen_l_button"), "OFF")
addPbaC(184, 228, XFlt("cl300/electr_apugen"),  XCmd("xap/apugen_button"),     "ON")
addPbaC(272, 228, XFlt("cl300/electr_gen_r"),   XCmd("xap/elec_gen_r_button"), "OFF")

-- ************************************************************************
-- ** LOWER
-- ************************************************************************
PANEL = PD:createInstance(LOWER, "RUN", 244, 16)
addTglS( 88,  44, XInt("cl300/en_but_run_l"), true, false, {maxval=1})
addTglS(192,  44, XInt("cl300/en_but_run_r"), true, false, {maxval=1})

PANEL = PD:createInstance(LOWER, "SPLRS", 244, 100)
addSw45( 88,  56, XInt("cl300/ground_sp_h"))
addCPbS(192,  48, XFlt("cl300/flight_spoil_h"), "OFF","RED")

PANEL = PD:createInstance(LOWER, "FLAPS", 524, 16)
addElem(130,  87, XFlt("sim/cockpit2/controls/flap_ratio"), SwitchType.new(IconFlaps, {step = 0.33333333, sound = SLrg}))

-- create pitch disc /gust lock after the central panels because it will overlap the other panels
PANEL = PD:createInstance(LOWER, "GUST", 16, 16)
PANEL:add( 88, 86, C300PitchDisc:createInstance(XInt("cl300/pitch_d_2")))
PANEL:add( 88, 86, C300PitchPull:createInstance(XInt("cl300/pitch_d_1"), PANEL:last()))
addElem(  219, 84, XInt("cl300/gust_lock"), SwitchType.new(IconGust, {sound = SLrg}))

PANEL = PD:createInstance(LOWER, "TRIM", 16, 188)
addElem( 60,  60, XFlt("cl300/trim_rud"), 
                  SwitchType.new(IconSwitch, {angle=2.7, minval=-1, step=.02, dial=true, interval=25, tics=50, keyword="DIA"}))
addSw45( 60, 140, XInt("cl300/trim_stab"), nil, {center = 0})
addCPbS( 60, 212, XInt("cl300/trim_pusher_h"), "OFF","RED")

PANEL = PD:createInstance(LOWER, "PARK", 136, 188)
addElem(124, 122, XFlt("sim/cockpit2/controls/parking_brake_ratio"), SwitchType.new(IconPBrake, {sound = SLrg}))

PANEL = PD:createInstance(LOWER, "TEST", 136, 436)
addElem(124,  56, XInt("cl300/test_rot"), C300Outer, {maxval = 7, center = 0, angle = 36, keyword = "ARR"})
addKeyM(124,  56, XInt("cl300/test_push"))

PANEL = PD:createInstance(LOWER, "ELT", 16, 532)
addElem(220,  52, XFlt("cl300/elt"),   C300LedRnd, {keyword = "RED"})
addTglS(292,  52, XInt("cl300/elt_h"), true, false, {maxval  = 1})
addKeyM( 76, 112, XInt("cl300/voice_rec_test"))
addElem(147, 112, XInt("cl300/voice_rec_test_lt"), C300LedRnd, {keyword = "GREEN"})

PANEL = PD:createInstance(LOWER, "CAB", 16, 688)
addCPbS( 76,  60, XInt("cl300/cab_dc_h"), "OFF","CLR")
addCPbS(148,  60, XInt("cl300/cab_ac_h"), "OFF","CLR")
addPbaS(220,  60, XFlt("cl300/cablight_h"), "ON")
addPbaS(292,  60, XFlt("cl300/entrlight_h"), "ON")

PANEL = PD:createInstance(LOWER, "AW", 16, 788)
addCPbS(112,  60, XInt("cl300/dcu_a_h"), "OFF","CLR")
addCPbS(256,  60, XInt("cl300/dcu_b_h"), "OFF","CLR")

PANEL = PD:createInstance(LOWER, "HYDR", 384, 188)
addCPbS( 76,  60, XInt("cl300/hydr_l_sov_h"), "CLOSED","CLR", {inverted = true})
addSw45(148,  68, XInt("cl300/l_hpump_h"))
addSw45(220,  68, XInt("cl300/r_hpump_h"))
addCPbS(292,  60, XInt("cl300/hydr_r_sov_h"), "CLOSED","CLR", {inverted = true})
addCPbS( 76, 136, XInt("cl300/hydr_altn_flp_h"), "ON",    "CLR")
addSw45(184, 144, XInt("cl300/ptu_h"), "DIA")
addSw45(292, 144, XInt("cl300/aux_hpump_h"), nil, nil, {maxval = 1, center = 1})

PANEL = PD:createInstance(LOWER, "ENG", 384, 364)
addCPbL( 76,  64, XInt("cl300/fire_engn_l_h"), "ENFIRE", "ENF")
addCPbS(184,  60, XInt("cl300/fire_apu_h"), "FIRE",   "RED")
addCPbL(292,  64, XInt("cl300/fire_engn_r_h"), "ENFIRE", "ENF")
addCPbS(148, 132, XInt("cl300/fire_ext_1_h"), "ARMED",  "RED")
addCPbS(220, 132, XInt("cl300/fire_ext_2_h"), "ARMED",  "RED")
addCPbS( 76, 208, XInt("cl300/fire_autoapr_h"), "OFF",    "RED")
addSw45(184, 216, XInt("sim/cockpit2/switches/jet_sync_mode"), "CIR")
addPbaS(292, 208, XInt("cl300/engn_mach_h"), "ON")
addSw45( 76, 292, XInt("cl300/en_starter_l"), nil, {momentary = {[2] = 1}})
addPbaS(184, 284, XInt("cl300/engn_ign_h"), "ON")
addSw45(292, 292, XInt("cl300/en_starter_r"), nil, {momentary = {[2] = 1}})

PANEL = PD:createInstance(LOWER, "APU", 384, 688)
addSw45( 64,  68, APU_Switch, nil, {momentary = {[2] = 1}})
addElem(248,  50, XInt("cl300/lg_man"), SwitchType.new(IconManGear, {sound = SLrg}))

PANEL = PD:createInstance(LOWER, "OXY", 384, 788)
addCPbS(112,  60, XInt("cl300/oxigen_terap_h"), "OFF","CLR")
addSw45(256,  68, XInt("cl300/oxigen_ox"))

-- ********** Deploy pages ***********************
local sounds = ENABLE_SOUNDS
ENABLE_SOUNDS = false
MAIN:deploy()
FMC:deploy()
UPPER:deploy()
LOWER:deploy()
HELPER:deploy()
ENABLE_SOUNDS = sounds

PAGE_MAIN:write(1)

-- ********* PREFLIGHT *******************************
local PREFLIGHT = button_add("PREFLIGHT.png", nil, 0, 936, 329, 34, function() xpl_command("cl300/preflight/fast_preflight") end)
xpl_dataref_subscribe("cl300/rembf1",  "INT",
                      "cl300/rembf2",  "INT",
                      "cl300/rembf3",  "INT",
                      "cl300/rembf4",  "INT",
                      "cl300/rembf5",  "INT",
                      "cl300/rembf6",  "INT",
                      "cl300/rembf7",  "INT",
                      "cl300/rembf8",  "INT",
                      "cl300/rembf9",  "INT",
                      "cl300/rembf10", "INT",
                      "cl300/rembf11", "INT",
                      "cl300/rembf12", "INT",
                      "cl300/rembf13", "INT",
                      "cl300/rembf14", "INT",
                      function(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14)
                        visible(PREFLIGHT, v1+v2+v3+v4+v5+v6+v7+v8+v9+v10+v11+v12+v13+v14 < 14)
                      end)
