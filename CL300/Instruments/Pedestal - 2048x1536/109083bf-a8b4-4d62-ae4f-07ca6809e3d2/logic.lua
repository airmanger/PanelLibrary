-- TODO: 
--[[
- Add control for gust lock
- Add page for preflight
- Add MCP and DCP control page
]]

-- EMPTY: Transparent image to be used for the invisible buttons.
EMPTY = "EMPTY.png"
-- ** Uncomment the next line to enable the red overlays to show the clickable areas:
--EMPTY = "RED.png"

-- NOCURSER: You can use this variably to override all cursors with a single graphic
-- Note that you cannot use a completely transparent image as cursor, therefore use a 
-- grey pixel/rectangle with 1% opacity if you want a invisible cursor
-- ** Uncomment the next line for transparent cursors if you use a touchscreen:
--NOCURSOR = "CURSOR EMPTY.png"  

-- ALLOW_REVERSE: If this is set to true, the up/down button will move the switch in the 
-- opposite direction (down/up) if the switch is already at its end of its movement. 
ALLOW_REVERSE = false

-- ZOOMABLE: If this is set to true, all panels except those with large handles
-- will be zoomable. 
-- ** Uncomment the next line for zoomable panels:
-- ZOOMABLE = true

-- CLASSIC_BUTTONS: If this is set to true, encoders and rotary switches will use the old button interface.
-- ** Uncomment the next line for 'classic' button interface:
--CLASSIC_BUTTONS = true

-- ************************************************************************
-- ** CURSORS
-- ************************************************************************
CursorZoom  = CursorSet.new("CURSOR ZOOM.png")
CursorPush  = CursorSet.new("CURSOR PUSH.png", nil, nil, "CURSOR NONE.png")
CursorPP    = CursorSet.new(nil, "CURSOR UP.png",          "CURSOR DOWN.png",  "CURSOR NONE.png")
CursorFlip  = CursorSet.new(nil, "CURSOR CLOSE.png",       "CURSOR OPEN.png",  "CURSOR NONE.png")
CursorTglH  = CursorSet.new(nil, "CURSOR LEFT.png",        "CURSOR RIGHT.png", "CURSOR NONE.png")
CursorTglV  = CursorSet.new(nil, "CURSOR DOWN.png",        "CURSOR UP.png",    "CURSOR NONE.png")
CursorTglVi = CursorSet.new(nil, "CURSOR UP.png",          "CURSOR DOWN.png")
CursorRotL  = CursorSet.new(nil, "CURSOR CCW LG.png",      "CURSOR CW LG.png", "CURSOR NONE.png") 
CursorRotS  = CursorSet.new(nil, "CURSOR CCW SM.png",      "CURSOR CW SM.png", "CURSOR NONE.png") 

-- ************************************************************************
-- ** RECTANGLES for click-able area of icons/buttons
-- ************************************************************************
CAToggleV   = Rectangle.new(  0,  0, 80,104) -- Vertical toggle switch
CAToggleDn  = Rectangle.new(  0, 26, 80, 52)
CAToggleUp  = Rectangle.new(  0,-26, 80, 52)
CAToggleH   = Rectangle.new(  0,  0,104, 80) -- Horizontal toggle switch
CAToggleLft = Rectangle.new(-26,  0, 52, 80)
CAToggleRgt = Rectangle.new( 26,  0, 52, 80)
CARotaryL   = Rectangle.new(-39,  0, 78, 78) -- Single large knob
CARotaryR   = Rectangle.new( 39,  0, 78, 78) 
CARotarySL  = Rectangle.new(-20,  0, 40, 60) -- Single small knob
CARotarySR  = Rectangle.new( 20,  0, 40, 60) 
CARotaryOL  = Rectangle.new(-78,  0, 78, 78) -- Dual knob, outer function
CARotaryOR  = Rectangle.new( 78,  0, 78, 78)
CARotaryID  = Rectangle.new(  0, 78, 78, 78) -- Dual knob, inner function
CARotaryIU  = Rectangle.new(  0,-78, 78, 78)
CACoverS    = Rectangle.new(  0,-63,108, 50) -- Covers for guarded Korrys
CACoverL    = Rectangle.new(  0,-74,140, 50)

-- ************************************************************************
-- ** ICONS 
-- ************************************************************************
IconKey       = Icon.new(nil, 62, 62, CursorPush)
IconLedRnd    = Icon.new({"LED RND %% 0.png",    "LED RND %% 1.png"},    26, 26)
IconLedBar    = Icon.new({"LED BAR %% 0.png",    "LED BAR %% 1.png"},    48, 22)

IconLedKorryS = Icon.new({"LED KORRY %% 0.png",  "LED KORRY %% 1.png",  "LED KORRY %% 2.png"},  68, 24)
IconLedKorryL = Icon.new({"LED KORRYL %% 0.png", "LED KORRYL %% 1.png", "LED KORRYL %% 2.png"}, 86, 36)

IconKorryS    = Icon.new({"KORRY SINGLE 0.png",  "KORRY SINGLE 1.png"},  76, 76, CursorPush)
IconKorryL    = Icon.new({"KORRY LARGE 0.png",   "KORRY LARGE 1.png"},   98, 98, CursorPush)

IconCoverS    = Icon.new({"COVER %% 0.png",      "COVER %% 1.png"},      88, 136, CursorFlip, CACoverS)
IconCoverL    = Icon.new({"COVERL %% 0.png",     "COVERL %% 1.png"},    120, 160, CursorFlip, CACoverL)

IconToggleV   = Icon.new({"TOGGLE VERT 0.png", "TOGGLE VERT 1.png", "TOGGLE VERT 2.png"},  40, 104, CursorTglV, CAToggleV, CAToggleDn,  CAToggleUp)
IconToggleH   = Icon.new({"TOGGLE HOR 0.png",  "TOGGLE HOR 1.png",  "TOGGLE HOR 2.png"},  104,  40, CursorTglH, CAToggleH, CAToggleLft, CAToggleRgt)

IconKnob      = Icon.new("KNOB %%.png",     78, 78, CursorRotL, nil, CARotaryL,  CARotaryR)
IconKnobOuter = Icon.new("KNOB %%.png",     78, 78, CursorRotL, nil, CARotaryOL, CARotaryOR)
IconKnobInner = Icon.new("KNOB INNER.png",  46, 46, CursorRotL, nil, CARotaryID, CARotaryIU)
IconKnobVolL  = Icon.new("KNOB VOL LG.png", 64, 64, CursorRotL, nil, CARotaryL,  CARotaryR)
IconKnobVolS  = Icon.new("KNOB VOL SM.png", 40, 40, CursorRotS, nil, CARotarySL, CARotarySR)

IconGear      = Icon.new({"HANDLE GEAR 0.png",    "HANDLE GEAR 1.png"},     49, 159, CursorTglVi, Rectangle.new(0,0,250,159))
IconPBrake    = Icon.new({"HANDLE BRAKE 0.png",   "HANDLE BRAKE 1.png"},    62, 704, CursorPP,    Rectangle.new(0,0,250,800))
IconManGear   = Icon.new({"HANDLE MANGEAR 0.png", "HANDLE MANGEAR 1.png"}, 392, 104, CursorPP,    Rectangle.new(0,0,400,150))
IconPitchRot  = Icon.new({"HANDLE PITCHDISC 0.png", "HANDLE PITCHDISC 1.png"},  96, 240, CursorRotL, nil, Rectangle.new(-100,0,100,240), Rectangle.new(100,0,100,240))
IconPitchPull = Icon.new(nil, 100, 240, CursorPP)

-- ************************************************************************
-- ** CONTROLS 
-- ************************************************************************
C300Key        = KeyType.new(IconKey,    {momentary = {0}})
C300AudioKey   = KeyType.new(IconKey)
C300LedRnd     = LEDType.new(IconLedRnd, {threshold = .1})
C300LedBar     = LEDType.new(IconLedBar, {threshold = .1, keyword = "GREEN"})

C300ToggleV    = SwitchType.new(IconToggleV, {maxval = 2})
C300ToggleH    = SwitchType.new(IconToggleH, {maxval = 2})
C300ToggleHM   = SwitchType.new(IconToggleH, {minval = -1, momentary =  {[-1] = 0, [1] = 0}})

C300Switch45   = SwitchType.new(IconKnob,      {angle = 45,    maxval = 2, keyword = "ARROW"})
C300Switch30   = SwitchType.new(IconKnob,      {angle = 30,    maxval = 2, keyword = "CIRCLE"})
C300Outer      = SwitchType.new(IconKnobOuter, {angle = 30,    maxval = 2, keyword = "CIRCLE"})
C300VolL       = SwitchType.new(IconKnobVolL,  {angle = 13.5,              step = -.05, dial = true, interval = 25 })
C300VolS       = SwitchType.new(IconKnobVolS,  {angle = 13.5,              step = -.05, dial = true, interval = 25 })
C300Bright     = SwitchType.new(IconKnob,      {angle = 19.25, minval =.3, step =  .05, dial = true, interval = 25, keyword = "CIRCLE"})
C300Temp       = SwitchType.new(IconKnob,      {angle = 13.5,  minval =-1, step =  .1,  dial = true, interval = 25, keyword = "CIRCLE"})

-- Special controls: 
C300Gear     = SwitchType.new(IconGear)
C300ManGear  = SwitchType.new(IconManGear)
C300Baro     = EncoderType.new(IconKnobOuter,   {angle = 12,    maxval = 30,              cycle = true,  interval = 100,            keyword = "BARO"})
C300LdgAlt   = EncoderType.new(IconKnobInner,   {angle = 12,    minval = -1, step  = .01, cycle = false, interval = 25,  tics = 50})
C300Trim     = SwitchType.new(IconKnob,         {angle = 2.7,   minval = -1, step  = .02, dial = true,   interval = 25,  tics = 50, keyword = "DIAMOND"})
C300PBrake   = SwitchType.new(IconPBrake)

-- We use a (invisible) Guard-object for the push/pull logic of the handle and a SwitchType-object for the rotation.
pitchDiscPushPullUpdateCallback = function(inst)
	local gi = inst.guardedInst[1]
	gi:disable(inst:lowerLimit())
	gi.imgNum = inst:getValue()+1
	gi.drawCallback(gi)
	gi.cursorCallback(gi)
end

C300PitchDisc = SwitchType.new(IconPitchRot, {angle = 45, minval = -1, dial = false})
C300PitchPull = GuardType.new(IconPitchPull, {unlocked = 0, updateCallback = pitchDiscPushPullUpdateCallback}) 

-- We need to get the selected dataref for the mfd from the toggle switch, which is stored as selectingInst.
mfdControlButtonPressedCallback = function(inst, dir)
    if inst.selectingInst ~= nil then
        inst.selected = inst.selectingInst:getValue() + 1
    end
    defaultPressedCallback(inst, dir)
end

C300MfdKey = KeyType.new(IconKey, {minval = 1, pressedCallback = mfdControlButtonPressedCallback}) -- Always set 1

-- PBAs
C300PBAL       = PBAType.new(IconKorryL, LEDType.new(IconLedKorryL, {threshold = {.1,.75}}))
C300PBAS       = PBAType.new(IconKorryS, LEDType.new(IconLedKorryS, {threshold = {.1,.75}}))
C300CoverS     = GuardType.new(IconCoverS)
C300CoverL     = GuardType.new(IconCoverL)

-- ************************************************************************
-- ** HELPERS
-- ************************************************************************
local PANEL
-- custom function to simplify PBA creation:

function addSmlPBA(x, y, key, dataref, opts)
    local refbase = string.sub(dataref.name, 0, string.len(dataref.name)-2) -- truncate "_h"-Postfix
    local refs = {dataref, XFlt(refbase)}
    local aopt = {opts, {keyword = key}}
    PANEL:add(x,y, C300PBAS:createInstance(refs, aopt))
end

function addDblPBA(x, y, key, dataref, opts, key2, postfix2)
    local refbase = string.sub(dataref.name, 0, string.len(dataref.name)-2) -- truncate "_h"-Postfix
    local refs = {dataref, XFlt(refbase), XFlt(refbase .. postfix2)}
    local aopt = {opts, {keyword = key}, {keyword = key2}}
    PANEL:add(x,y, C300PBAS:createInstance(refs, aopt))
end

function addCmdPBA(x, y, key, cmd, dataref, opts)
    if opts == nil then opts = {momentary = {0}} else opts.momentary = {0} end
    local refs = {cmd, dataref}
    local aopt = {opts, {keyword = key}}
    PANEL:add(x,y, C300PBAS:createInstance(refs, aopt))
end

function addCovPBA(x, y, key, cov, dataref, opts)
    local pbat = C300PBAS
    local covt = C300CoverS
    local refbase = string.sub(dataref.name, 0, string.len(dataref.name)-2) -- truncate "_h"-Postfix
    local refs = {dataref, XFlt(refbase)}
    local aopt = {opts, {keyword = key}}
    PANEL:add(x,y, pbat:createInstance(refs, aopt))
    PANEL:add(x,y, covt:createInstance(DataRef.new(KIND_XP, refbase .. "_cov", dataref.datatype), PANEL:last(), {keyword = cov}))
end

function addCLgPBA(x, y, key, cov, dataref, opts)
    local pbat = C300PBAL
    local covt = C300CoverL
    local refbase = string.sub(dataref.name, 0, string.len(dataref.name)-2) -- truncate "_h"-Postfix
    local refs = {dataref, XFlt(refbase)}
    local aopt = {opts, {keyword = key}}
    
    PANEL:add(x,y, pbat:createInstance(refs, aopt))
    PANEL:add(x,y, covt:createInstance(DataRef.new(KIND_XP, refbase .. "_cov", dataref.datatype), PANEL:last(), {keyword = cov}))
end

function addCL3S45(x, y, key, dataref, opts)
    if opts ~= nil then opts.keyword = key else opts = {keyword = key} end
    PANEL:add(x,y, C300Switch45:createInstance(dataref, opts))
end

function addCL3S30(x, y, key, dataref, opts)
    if opts ~= nil then opts.keyword = key else opts = {keyword = key} end
    PANEL:add(x,y, C300Switch30:createInstance(dataref, opts))
end

function addCL3MFD(x, y, baseref, opts)
    PANEL:add(x, y, C300MfdKey:createInstance({XInt(baseref .. "_l"), XInt(baseref .. "_r")}, opts))
end


-- ************************************************************************
-- ** PANEL TYPES
-- ************************************************************************
local PD = PanelType.new("BASE %%.png",true)
local PZ
if ZOOMABLE then
    PZ = PanelType.new("BASE %%.png",false):addZoomedPane(2,true, CursorZoom):addZoomedShadow("SHADOW %%.png", 14)
    -- Demo for zoomable panels that appear at a fixed location. Set the preferred resolution to 2048x2048 to test this:
    -- PZ = PanelType.new("BASE %%.png",false):addZoomedPane(1.5,true, CursorZoom, 1024, 1792):addZoomedShadow("SHADOW %%.png", 14)
else
    PZ = PD
end

-- ************************************************************************
-- ** UPPER PEDESTAL 
-- ************************************************************************
img_add_fullscreen("BG.png")
local UPPER = Page.new(nil, true)
local LOWER = Page.new(nil, false)

PANEL = UPPER:add(PZ:createInstance("BAROCOMP",352,144, 660,244))
PANEL:add(138, 138, C300Baro:createInstance(    XCmd("sim/instruments/barometer_up", "sim/instruments/barometer_down")))
PANEL:add(138, 138, C300Key:createInstance(     XCmd("sim/instruments/barometer_2992")))
addSmlPBA(330, 138, "DG",                       XInt("cl300/comps_head_l_h"))
PANEL:add(522, 138, C300ToggleHM:createInstance(XInt("cl300/comps_slew_l_sw")))

PANEL = UPPER:add(PZ:createInstance("TAWS",352,472, 660,388))
addCovPBA(138, 122, "OFF","CLR", XInt("cl300/taws_gs_h"))
addCovPBA(330, 122, "OFF","CLR", XInt("cl300/taws_flp_h"))
addCovPBA(522, 122, "OFF","CLR", XInt("cl300/taws_ter_h"))
addSmlPBA(138, 314, "OFF",       XInt("cl300/nws_h"))
PANEL:add(426, 298, C300Gear:createInstance(XInt("sim/cockpit2/controls/gear_handle_down")))

PANEL = UPPER:add(PZ:createInstance("FUEL",352,860, 660,364))
addSmlPBA(330, 130, "BAR", XInt("cl300/fuel_xflow_up_h"))
addSmlPBA(330, 290, "BAR", XInt("cl300/fuel_xflow_dn_h"))
addCL3S45(138, 290, nil,   XInt("cl300/fuel_xpump_l"))
addCL3S45(522, 290, nil,   XInt("cl300/fuel_xpump_r"))

PANEL = UPPER:add(PZ:createInstance("SYSTEMS",352,1232, 660,356))
addCL3S30(138, 138, nil, XInt("cl300/rev_pan_l"))
addCL3S30(330, 138, nil, XInt("cl300/rev_tune"), {maxval=3,center=2})
addCL3S30(522, 138, nil, XInt("cl300/rev_pan_r"))
addCL3S30(218, 282, nil, XInt("cl300/rev_att_hd"))
addCL3S30(426, 282, nil, XInt("cl300/rev_air_dat"))

PANEL = UPPER:add(PZ:createInstance("ACBLEED",1024,276, 660,508))
PANEL:add(138, 122, C300Temp:createInstance(XFlt("cl300/aircond_cockpit_temp")))
PANEL:add(522, 122, C300Temp:createInstance(XFlt("cl300/aircond_cabin_temp")))
addCL3S45(330, 274, nil,         XInt("cl300/aircond_airsource"), {maxval=3,center=1})
addSmlPBA(330, 114, "ON",        XInt("cl300/aircond_man_temp_h"))
addCovPBA(138, 274, "ON", "CLR", XInt("cl300/aircond_ramair_h"))
addSmlPBA(522, 274, "ON",        XInt("cl300/bleed_apu_h"))
addSmlPBA(138, 434, "OFF",       XInt("cl300/bleed_en_l_h"))
addSmlPBA(330, 434, "BAR",       XInt("cl300/bleed_xbleed_h"))
addSmlPBA(522, 434, "OFF",       XInt("cl300/bleed_en_r_h"))

PANEL = UPPER:add(PZ:createInstance("ANTIICE",1024,716, 660,348))
addCL3S45(138, 138, nil,   XInt("cl300/antice_wngsource_r"))
addSmlPBA(266, 114, "ON",  XInt("cl300/antice_wing_h"))
addSmlPBA(394, 114, "OFF", XInt("cl300/antice_probe_l_h"))
addSmlPBA(522, 114, "OFF", XInt("cl300/antice_probe_r_h"))
addSmlPBA(138, 274, "ON",  XInt("cl300/antice_engn_l_h"))
addSmlPBA(266, 274, "ON",  XInt("cl300/antice_engn_r_h"))
addSmlPBA(394, 274, "OFF", XInt("cl300/antice_wshld_l_h"))
addSmlPBA(522, 274, "OFF", XInt("cl300/antice_wshld_r_h"))

PANEL = UPPER:add(PZ:createInstance("ELECTRICAL",1024,1156, 660,508))
addSmlPBA(170, 114, "OFF", XInt("cl300/left_bat_h"))
addDblPBA(330, 114, "ON",  XInt("cl300/electr_extp_h"), nil, "AVAIL", "_avail")
addSmlPBA(490, 114, "OFF", XInt("cl300/right_bat_h"))
addSmlPBA( 74, 194, "OFF", XInt("cl300/electr_stbi_h"))
addCmdPBA(330, 274, "BAR", XCmd("xap/bus_tie_h_button"),  XFlt("cl300/bus_tie"))
addCmdPBA(170, 434, "OFF", XCmd("xap/elec_gen_l_button"), XFlt("cl300/electr_gen_l"))
addCmdPBA(330, 434, "ON",  XCmd("xap/apugen_button"),     XFlt("cl300/electr_apugen"))
addCmdPBA(490, 434, "OFF", XCmd("xap/elec_gen_r_button"), XFlt("cl300/electr_gen_r"))

PANEL = UPPER:add(PZ:createInstance("PRESSURE",1696,196, 660,348))
PANEL:add(138, 122, C300Temp:createInstance(  XFlt("cl300/pressure_manrate"),    {keyword = "ARROW"}))
PANEL:add(522, 210, C300Outer:createInstance( XInt("cl300/pressure_lndg_alt_1"), {keyword = "OUTER"}))
PANEL:add(522, 210, C300LdgAlt:createInstance(XFlt("cl300/pressure_lndg_alt_2")))
addSmlPBA(330, 114, "ON",        XInt("cl300/pressure_man_h"))
addCovPBA(138, 274, "ON", "RED", XInt("cl300/pressure_emer_depr_h"))
addCovPBA(330, 274, "ON", "RED", XInt("cl300/pressure_ditch_h"))

PANEL = UPPER:add(PZ:createInstance("EXT LIGHT",1696,576, 660,388))
PANEL:add(138, 138, C300ToggleV:createInstance(XFlt("cl300/wing_insp_h"), {maxval=1}))
PANEL:add(266, 138, C300ToggleV:createInstance(XFlt("cl300/nav_h")))
PANEL:add(394, 138, C300ToggleV:createInstance(XFlt("cl300/strobe_h")))
PANEL:add(522, 138, C300ToggleV:createInstance(XInt("cl300/smokebelts_h")))
PANEL:add(138, 298, C300ToggleV:createInstance(XFlt("cl300/emeright_h")))
PANEL:add(266, 298, C300ToggleV:createInstance(XFlt("cl300/landlight1_h"), {maxval=1}))
PANEL:add(394, 298, C300ToggleV:createInstance(XFlt("cl300/xap_taxilight_h")))
PANEL:add(522, 298, C300ToggleV:createInstance(XFlt("cl300/landlight2_h"), {maxval=1}))

PANEL = UPPER:add(PZ:createInstance("INT LIGHT",1696,880, 660,196))
addCL3S45(138, 122, nil, XFlt("cl300/annun_h"), {angle = 60, maxval=1, center=.5})
PANEL:add(266, 122, C300Bright:createInstance({XFlt("cl300/gshldl_h"), XFlt("cl300/gshldr_h")}))
PANEL:add(394, 122, C300Bright:createInstance({XFlt("cl300/cmfd_h"),   XFlt("cl300/cpfd_h"), XFlt("cl300/pmfd_h"), XFlt("cl300/ppfd_h")}))
PANEL:add(522, 122, C300Bright:createInstance({XFlt("cl300/cbp_h"),    XFlt("cl300/dome_h"), XFlt("cl300/pedestal_h")}))

PANEL = UPPER:add(PZ:createInstance("AUDIO",1696,1200, 660,420))
PANEL:add( 90,  50, C300LedBar:createInstance(XFlt("cl300/aud_com1_l")))
PANEL:add(170,  50, C300LedBar:createInstance(XFlt("cl300/aud_com2_l")))
PANEL:add(250,  50, C300LedBar:createInstance(XFlt("cl300/aud_com3_l")))
PANEL:add(330,  50, C300LedBar:createInstance(XFlt("cl300/aud_hf1_l")))
PANEL:add(410,  50, C300LedBar:createInstance(XFlt("cl300/aud_hf2_l")))
PANEL:add(490,  50, C300LedBar:createInstance(XFlt("cl300/aud_cab_l")))
PANEL:add(570,  50, C300LedBar:createInstance(XFlt("cl300/aud_pa_l")))

PANEL:add( 90,  90, C300AudioKey:createInstance(XInt("cl300/aud_com1_l_h")))
PANEL:add(170,  90, C300AudioKey:createInstance(XInt("cl300/aud_com2_l_h")))
PANEL:add(250,  90, C300AudioKey:createInstance(XInt("cl300/aud_com3_l_h")))
PANEL:add(330,  90, C300AudioKey:createInstance(XInt("cl300/aud_hf1_l_h")))
PANEL:add(410,  90, C300AudioKey:createInstance(XInt("cl300/aud_hf2_l_h")))
PANEL:add(490,  90, C300AudioKey:createInstance(XInt("cl300/aud_cab_l_h")))
PANEL:add(570,  90, C300AudioKey:createInstance(XInt("cl300/aud_pa_l_h")))

PANEL:add( 90, 178, C300VolS:createInstance(XFlt("cl300/aud_vol_1_l")))
PANEL:add(170, 178, C300VolS:createInstance(XFlt("cl300/aud_vol_2_l")))
PANEL:add(250, 178, C300VolS:createInstance(XFlt("cl300/aud_vol_3_l")))
PANEL:add(330, 178, C300VolS:createInstance(XFlt("cl300/aud_vol_4_l")))
PANEL:add(410, 178, C300VolS:createInstance(XFlt("cl300/aud_vol_5_l")))
PANEL:add(490, 178, C300VolS:createInstance(XFlt("cl300/aud_vol_6_l")))
PANEL:add(570, 178, C300VolS:createInstance(XFlt("cl300/aud_vol_7_l")))
PANEL:add( 90, 266, C300VolS:createInstance(XFlt("cl300/aud_vol_8_l")))
PANEL:add(170, 266, C300VolS:createInstance(XFlt("cl300/aud_vol_9_l")))
PANEL:add(250, 266, C300VolS:createInstance(XFlt("cl300/aud_vol_10_l")))
PANEL:add(330, 266, C300VolS:createInstance(XFlt("cl300/aud_vol_11_l")))
PANEL:add(410, 266, C300VolS:createInstance(XFlt("cl300/aud_vol_12_l")))
PANEL:add(490, 266, C300VolS:createInstance(XFlt("cl300/aud_vol_13_l")))
PANEL:add(570, 266, C300VolS:createInstance(XFlt("cl300/aud_vol_14_l")))
PANEL:add( 90, 354, C300VolS:createInstance(XFlt("cl300/aud_vol_15_l")))
PANEL:add(170, 354, C300VolS:createInstance(XFlt("cl300/aud_vol_16_l")))
PANEL:add(530, 354, C300VolL:createInstance(XFlt("cl300/aud_vol_17_l")))

PANEL:add(250, 354, C300ToggleV:createInstance(XInt("cl300/aud_voice_l_sw")))
PANEL:add(330, 354, C300ToggleV:createInstance(XInt("cl300/aud_emer_l_sw"), {maxval=1}))
PANEL:add(410, 354, C300ToggleV:createInstance(XInt("cl300/aud_o2m_l_sw"),  {maxval=1}))

UPPER:addPageButton("PAGE DOWN.png", LOWER, Rectangle.new(1024, 1468, 2004, 92), CursorZoom)
UPPER:deploy()

-- ************************************************************************
-- ** LOWER PEDESTAL 
-- ************************************************************************

PANEL = LOWER:add(PZ:createInstance("SPOILER",480,120, 404,196))
addCL3S45(138, 138, nil,         XInt("cl300/ground_sp_h"))
addCovPBA(266, 122, "OFF","RED", XFlt("cl300/flight_spoil_h"))

PANEL = LOWER:add(PZ:createInstance("MFD",352,440, 660,420))
PANEL:add(138,  90, C300Key:createInstance(XInt("cl300/mfd_pan_cas")))
PANEL:add(294, 134, C300Key:createInstance(XCmd("cl300/chklist_jleft")))
PANEL:add(366, 134, C300Key:createInstance(XCmd("cl300/chklist_jright")))
PANEL:add(186, 178, C300Key:createInstance(XCmd("cl300/chklist_skip")))
PANEL:add(426, 266, C300Key:createInstance(XCmd("cl300/chklist_enter")))
PANEL:add(186, 266, C300Key:createInstance(XInt("sim/cockpit2/EFIS/EFIS_tcas_on")))
PANEL:add(282, 266, C300Key:createInstance(XInt("sim/cockpit2/EFIS/EFIS_weather_on")))
PANEL:add(506, 134, C300ToggleH:createInstance(XInt("cl300/mfdpan_lr_sw"), {maxval=1}))
C300MfdKey.selectingInst = PANEL:last()
addCL3MFD( 90, 178, "cl300/mfd_checkl")
addCL3MFD( 90, 266, "cl300/mfd_frmt", {minval = 0, maxval = 6, step = 1, cycle = true})
addCL3MFD(570, 266, "cl300/mfd_sumry")
addCL3MFD( 90, 354, "cl300/mfd_antice")
addCL3MFD(186, 354, "cl300/mfd_ecs")
addCL3MFD(282, 354, "cl300/mfd_electr")
addCL3MFD(378, 354, "cl300/mfd_flt_ctr")
addCL3MFD(474, 354, "cl300/mfd_fuel")
addCL3MFD(570, 354, "cl300/mfd_hydr")

-- create pitch disc after mfd because the pulled handle will overlap over the mfd panel
PANEL = LOWER:add(PD:createInstance("PITCH",144,120, 244,196))
PANEL:add(122, 98, C300PitchDisc:createInstance(XInt("cl300/pitch_d_2")))
PANEL:add(122, 98, C300PitchPull:createInstance(XInt("cl300/pitch_d_1"), PANEL:last()))

PANEL = LOWER:add(PZ:createInstance("ELT",352,828, 660,332))
PANEL:add(394, 106, C300LedRnd:createInstance( XFlt("cl300/elt"),              {keyword = "RED"}))
PANEL:add(522, 106, C300ToggleV:createInstance(XInt("cl300/elt_h"),            {maxval  = 1}))
PANEL:add(138, 242, C300Key:createInstance(    XInt("cl300/voice_rec_test"),   {momentary = {[1] = 0}}))
PANEL:add(266, 242, C300LedRnd:createInstance( XInt("cl300/voice_rec_test_lt"),{keyword = "GREEN"}))
-- cl300/crc_butt

PANEL = LOWER:add(PZ:createInstance("OXY",352,1104, 660,196))
addCovPBA(138, 122, "OFF","CLR", XInt("cl300/oxigen_terap_h"))
addCL3S45(266, 138, nil,         XInt("cl300/oxigen_ox"))
addCovPBA(394, 122, "OFF","CLR", XInt("cl300/dcu_a_h"))
addCovPBA(522, 122, "OFF","CLR", XInt("cl300/dcu_b_h"))

PANEL = LOWER:add(PZ:createInstance("CABIN",352,1312, 660,196))
addCovPBA(138, 122, "OFF","CLR", XInt("cl300/cab_dc_h"))
addCovPBA(266, 122, "OFF","CLR", XInt("cl300/cab_ac_h"))
addSmlPBA(394, 122, "ON",        XFlt("cl300/cablight_h"))
addSmlPBA(522, 122, "ON",        XFlt("cl300/entrlight_h"))

PANEL = LOWER:add(PD:createInstance("FLAPS",800,120, 212,196))

PANEL = LOWER:add(PZ:createInstance("CUTOFF",1136,120, 436,196))
PANEL:add(138, 122, C300ToggleV:createInstance(XInt("cl300/en_but_run_l"), {maxval=1}))
PANEL:add(298, 122, C300ToggleV:createInstance(XInt("cl300/en_but_run_r"), {maxval=1}))

PANEL = LOWER:add(PZ:createInstance("TRIM",800,685, 212,908))
PANEL:add(106, 122, C300Trim:createInstance(XFlt("cl300/trim_rud")))
addCL3S45(106, 282, nil,         XInt("cl300/trim_stab"), {center = 0})
addCovPBA(106, 426, "OFF","RED", XInt("cl300/trim_pusher_h"))

PANEL = LOWER:add(PD:createInstance("BRAKE",1136, 685, 436,908))
PANEL:add(218, 474, C300PBrake:createInstance(XFlt("sim/cockpit2/controls/parking_brake_ratio")))

PANEL = LOWER:add(PZ:createInstance("TEST",1024,1280, 660,260))
PANEL:add(330, 138, C300Outer:createInstance(XInt("cl300/test_rot"),  {maxval = 7, center = 0, angle = 36, keyword = "ARROW"}))
PANEL:add(330, 138, C300Key:createInstance(  XInt("cl300/test_push"), {momentary = {[1] = 0}}))

PANEL = LOWER:add(PZ:createInstance("HYDRAULIC",1696,280, 660,516))
addCL3S45(138, 298,  nil,           XInt("cl300/l_hpump_h"))
addCL3S45(522, 298,  nil,           XInt("cl300/r_hpump_h"))
addCL3S45(330, 378, "DIAMOND",      XInt("cl300/ptu_h"))
addCL3S45(522, 458,  nil,           XInt("cl300/aux_hpump_h"))
addCovPBA(138, 122, "CLOSED","CLR", XInt("cl300/hydr_l_sov_h"), {inverted = true})
addCovPBA(522, 122, "CLOSED","CLR", XInt("cl300/hydr_r_sov_h"), {inverted = true})
addCovPBA(138, 442, "ON",    "CLR", XInt("cl300/hydr_altn_flp_h"))

PANEL = LOWER:add(PZ:createInstance("ENGINE",1696,876, 660,652))
addCLgPBA(138, 130, "FIRE", "RED", XInt("cl300/fire_engn_l_h"))
addCovPBA(330, 122, "FIRE", "RED", XInt("cl300/fire_apu_h"))
addCLgPBA(522, 130, "FIRE", "RED", XInt("cl300/fire_engn_r_h"))
addCovPBA(266, 282, "ARMED","RED", XInt("cl300/fire_ext_1_h"))
addCovPBA(394, 282, "ARMED","RED", XInt("cl300/fire_ext_2_h"))
addCovPBA(138, 442, "OFF",  "RED", XInt("cl300/fire_autoapr_h"))
addSmlPBA(522, 442, "ON",          XInt("cl300/engn_mach_h"))
addSmlPBA(330, 586, "ON",          XInt("cl300/engn_ign_h"))
addCL3S45(330, 458, "CIRCLE",      XInt("sim/cockpit2/switches/jet_sync_mode"))
addCL3S45(138, 602,  nil,          XInt("cl300/en_starter_l"), {momentary = {[2] = 1}})
addCL3S45(522, 602,  nil,          XInt("cl300/en_starter_r"), {momentary = {[2] = 1}})
-- Event LED: Not defined yet: 521, 281

PANEL = LOWER:add(PZ:createInstance("APU",1472,1312, 212,196))
addCL3S45(106, 114, nil, XInt("sim/cockpit/engine/APU_switch"), {momentary = {[2] = 1}})
--sim/cockpit/engine/APU_switch
--sim/cockpit2/electrical/APU_starter_switch

PANEL = LOWER:add(PD:createInstance("MANGEAR",1808,1312, 436,196))
PANEL:add(218,  98, C300ManGear:createInstance(XInt("cl300/lg_man")))

LOWER:addPageButton("PAGE UP.png", UPPER, Rectangle.new(1024, 1468, 2004, 92), CursorZoom)
LOWER:deploy()
