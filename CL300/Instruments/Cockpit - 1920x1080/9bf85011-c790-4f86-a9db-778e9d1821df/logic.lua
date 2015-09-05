-- EMPTY: Transparent image to be used for the invisible buttons.
EMPTY = "!EMPTY.png"
DIAL  = "!DIAL.png"
-- ** Uncomment the next line to enable the red overlays to show the clickable areas:
--EMPTY = "!RED.png"
--DIAL  = "!DIAL_CYAN.png"

-- ALLOW_REVERSE: If this is set to true, the up/down button will move the switch in the 
-- opposite direction (down/up) if the switch is already at its end of its movement. 
ALLOW_REVERSE = false

-- CLASSIC_BUTTONS: If this is set to true, encoders and rotary switches will use the old button interface.
-- ** Uncomment the next line for 'classic' button interface:
--CLASSIC_BUTTONS = true

-- ************************************************************************
-- ** COMMANDS: Custom commands
-- ************************************************************************
function clear_master_alerts(phase)
    xpl_command("sim/annunciator/clear_master_warning")
    xpl_command("sim/annunciator/clear_master_caution")
end
local CLEAR_ALERTS = ICmd("int/clear_master_alerts", nil, clear_master_alerts)

function alt_alert_cancel(phase)
    -- if distance to alt > 200 ft while in alt hold, the alt envelope 
    -- should begin to flash on the pfd as alert... this will be cancelled
    -- by this button, but so far the functionality hasn't been implemented.
    print("altitude hold alert cancel")
end
local CANCEL_ALT_ALERT = ICmd("int/alt_alert_cancle",nil, alt_alert_cancel)

-- VS WHEEL --------------------------------------------------------------
local AP_VS = 0
local AP_VS_MODE = 0
local AP_PITCH_MODE = 0

function update_vs(vs, vsm, pitchm) 
    AP_VS = vs
    AP_VS_MODE = vsm
    AP_PITCH_MODE = pitchm
end
 xpl_dataref_subscribe("sim/cockpit2/autopilot/vvi_dial_fpm", "FLOAT",
                       "sim/cockpit2/autopilot/vvi_status", "INT", 
                       "sim/cockpit2/autopilot/pitch_status",  "INT", update_vs)
                       
function vs_wheel_up()
    if AP_VS_MODE > 0 then
        local vs = var_round(AP_VS / 100, 0) * 100 + 100
        xpl_dataref_write("sim/cockpit2/autopilot/vvi_dial_fpm", "FLOAT", vs)
    elseif AP_PITCH_MODE > 0 then
        xpl_command("sim/autopilot/nose_up_pitch_mode")
    end
end
function vs_wheel_down()
    if AP_VS_MODE > 0 then
        local vs = var_round(AP_VS / 100, 0) * 100 - 100
        xpl_dataref_write("sim/cockpit2/autopilot/vvi_dial_fpm", "FLOAT", vs)
    elseif AP_PITCH_MODE > 0 then
        xpl_command("sim/autopilot/nose_down_pitch_mode")
    end
end
local VS_WHEEL = ICmd("int/vs_wheel_up", "int/vs_wheel_down", vs_wheel_up, vs_wheel_down)

-- IAS/MACH -----------------------------------------------------------------------
local AP_SPEED  = 0
local AP_ISMACH = 0
function update_spd(spd, im) 
    AP_SPEED = spd
    AP_ISMACH = im
end
 xpl_dataref_subscribe("sim/cockpit2/autopilot/airspeed_dial_kts_mach", "FLOAT", 
                       "sim/cockpit2/autopilot/airspeed_is_mach", "INT", 
                       update_spd)

function airspeed_up()
    local spd
    if AP_ISMACH > 0 then
        spd = var_round(AP_SPEED, 2) + 0.01
    else
        spd = var_round(AP_SPEED, 0) + (AP_SPEED >= 150 and 2 or 1)
    end
    xpl_dataref_write("sim/cockpit2/autopilot/airspeed_dial_kts_mach", "FLOAT", spd)
end
function airspeed_down()
    local spd 
    if AP_ISMACH > 0 then
        spd = var_round(AP_SPEED, 2) - 0.01
    else
        spd = var_round(AP_SPEED, 0) - (AP_SPEED > 150 and 2 or 1)
    end
    xpl_dataref_write("sim/cockpit2/autopilot/airspeed_dial_kts_mach", "FLOAT", spd)
end
local SPD_DIAL = ICmd("int/airspeed_up", "int/airspeed_down", airspeed_up, airspeed_down)

-- CRS/HDG -----------------------------------------------------------------------
local AP_CRS = 0
local AP_HDG = 0
function update_crs_hdg(crs, hdg) 
    AP_CRS = crs
    AP_HDG = hdg
end
 xpl_dataref_subscribe("sim/cockpit2/radios/actuators/hsi_obs_deg_mag_pilot", "FLOAT", 
                       "sim/cockpit2/autopilot/heading_dial_deg_mag_pilot", "FLOAT", 
                       update_crs_hdg)
    
function crs_up()
    local crs = var_round(AP_CRS, 0) + 1
    if crs > 359 then crs = crs - 360 end
    xpl_dataref_write("sim/cockpit2/radios/actuators/hsi_obs_deg_mag_pilot", "FLOAT", crs)
end
function crs_down()
    local crs = var_round(AP_CRS, 0) - 1
    if crs < 0 then crs = crs + 360 end
    xpl_dataref_write("sim/cockpit2/radios/actuators/hsi_obs_deg_mag_pilot", "FLOAT", crs)
end
local CRS_DIAL = ICmd("int/crs_up", "int/crs_down", crs_up, crs_down)

function hdg_up()
    local crs = var_round(AP_HDG, 0) + 1
    if crs > 359 then crs = crs - 360 end
    xpl_dataref_write("sim/cockpit2/autopilot/heading_dial_deg_mag_pilot", "FLOAT", crs)
end
function hdg_down()
    local crs = var_round(AP_HDG, 0) - 1
    if crs < 0 then crs = crs + 360 end
    xpl_dataref_write("sim/cockpit2/autopilot/heading_dial_deg_mag_pilot", "FLOAT", crs)
end
local HDG_DIAL = ICmd("int/hdg_up", "int/hdg_down", hdg_up, hdg_down)

-- ALT -----------------------------------------------------------------------
local AP_ALT = 0
function update_alt(alt) 
    AP_ALT = alt
end
 xpl_dataref_subscribe("sim/cockpit2/autopilot/altitude_dial_ft", "FLOAT", 
                       update_alt)
    
function alt_up()
    local alt = var_round(AP_ALT / 100, 0) * 100 + 100
    xpl_dataref_write("sim/cockpit2/autopilot/altitude_dial_ft", "FLOAT", alt)
end
function alt_down()
    local alt = var_round(AP_ALT / 100, 0) * 100 - 100
    xpl_dataref_write("sim/cockpit2/autopilot/altitude_dial_ft", "FLOAT", alt)
end
local ALT_DIAL = ICmd("int/alt_up", "int/alt_down", alt_up, alt_down)

-- ************************************************************************
-- ** XFMC
-- ************************************************************************
local XfmcLines = {large = {}, small = {}}

function convertXFMCstring(str) 
    print("called ..." .. string.len(str))
    local small = ""
    local large = ""
    local i = str:find("/")
    if i == nil then return "" end
    
    local page = str:sub(1, i-1)
    str = str:sub(i+1)
    
    while str:len() > 0 do
        i = str:find(";")
        local segment
        if i ~= nil then
            segment = str:sub(1,i-1)
            str = str:sub(i+1)
        else
            segment = str
            str = ""
        end
        i = segment:find(",", 3)
        local islrg  = (segment:sub(1,1) == "1")
        print(segment:sub(1,1) .. " = " .. tostring(islrg))
        local column = tonumber(segment:sub(3,i-1))
        local chunk  = segment:sub(i+1)
        
        local pad = math.floor(column/6.85+.5) - small:len() - 1
        if pad > 0 then
            small = small .. string.rep(" ", pad)
            large = large .. string.rep(" ", pad)
        end
        
        for i = 1,chunk:len() do
            -- Small fonts have a offset of 128(d) 0x80(hex).
            -- The asterix char (*) has been translated from 176(d) to 30(d).
            -- The box char [] has been translated to 31 (d)
            local c = chunk:byte(i)
            local il = islarge
            if c == 30 then c = 176
            elseif c == 31 then c = 35
            elseif c > 128 then c = c - 128; il = false
            else il = true end
            
            large = large .. (il and string.char(c) or " ")
            small = small .. (il and " " or string.char(c))
        end
    end
    print("/lg = " .. large)
    print("/sm = " .. small)
    return {large, small}
end

for num = 1, 15 do
    local xvar = "xfmc/Panel_" .. (num-1)
    if     num == 1  then xvar = "xfmc/Upper"
    elseif num == 14 then xvar = "xfmc/Scratch"
    elseif num == 15 then xvar = "xfmc/Messages"
    end
    
    XfmcLines.large[num] = am_variable_create("fmc/lines/lg_" .. num, "BYTE[30]", "")
    XfmcLines.small[num] = am_variable_create("fmc/lines/sm_" .. num, "BYTE[30]", "")
    
    xpl_dataref_subscribe(xvar,"BYTE[80]",
        function(val) 
            print("**** " .. tostring(val))
            local lines = convertXFMCstring(val)
            am_variable_write(XfmcLines.large[num], lines[1])
            am_variable_write(XfmcLines.small[num], lines[2])
        end)
end

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
IconKey       = Icon.new(nil, 44, 32)
IconKeyAPDisc = Icon.new(nil, 70, 32)

IconLedRnd    = Icon.new({"LED_RND_%%_BRT.png"},    11, 11)
IconLedBar    = Icon.new({"LED_BAR_%%_BRT.png"},    22, 9)
IconLedFMC    = Icon.new({"LED_FMC_BRT.png"},    40, 8)

IconPage     = Icon.new({"", "PAGE_%%.png"}, 234, 33) 

IconLedKorryS = Icon.new({"A_%%_OFF.png",  "A_%%_DIM.png",  "A_%%_BRT.png"}, 34, 12)
IconLedKorryL = Icon.new({"A_%%_OFF.png",  "A_%%_DIM.png",  "A_%%_BRT.png"}, 43, 18)

IconKorryS    = Icon.new({"PBA_SM_OFF.png", "PBA_SM_ON.png"}, 38, 38)
IconKorryL    = Icon.new({"PBA_LG_OFF.png", "PBA_LG_ON.png"}, 49, 49)

IconCoverS    = Icon.new({"COV_%%_CLSD.png", "COV_%%_OPEN.png"}, 44, 68, nil, CACoverS)
IconCoverL    = Icon.new({"COV_%%_CLSD.png", "COV_%%_OPEN.png"}, 60, 80, nil, CACoverL)

IconToggleV   = Icon.new({"TGL_V_D.png", "TGL_V_C.png", "TGL_V_U.png"},  20, 52, nil, CAToggleV, CAToggleDn,  CAToggleUp)
IconToggleH   = Icon.new({"TGL_H_L.png", "TGL_H_C.png", "TGL_H_R.png"},  52, 20, nil, CAToggleH, CAToggleLft, CAToggleRgt)

IconSwitch    = Icon.new("SW_%%.png",      39, 39, nil, nil, CARotaryL,  CARotaryR)
IconSwitchO   = Icon.new("SW_%%.png",      39, 39, nil, nil, CARotaryOL, CARotaryOR)
IconVolumeL   = Icon.new("VOL_LG.png",     32, 32, nil, nil, CARotaryL,  CARotaryR)
IconVolumeS   = Icon.new("VOL_SM.png",     20, 20, nil, nil, CARotarySL, CARotarySR)
IconEncoderO  = Icon.new("ENC_%%_OUT.png", 39, 39, nil, nil, CARotaryOL, CARotaryOR)
IconEncoderI  = Icon.new("ENC_%%_INN.png", 23, 23, nil, Rectangle.new(0,0,23,23), CARotaryID, CARotaryIU)
IconEncoderW  = Icon.new({"ENC_VS_0.png","ENC_VS_1.png","ENC_VS_2.png","ENC_VS_3.png"}, 32, 84, nil, Rectangle.new(0,0,40,40), Rectangle.new(0,42,32,42), Rectangle.new(0,-42,32,42))
IconEncoderPS = Icon.new("ENC_%%.png", 25, 25, nil, CARotaryPB) -- single encoder pushbutton
IconEncoderPD = Icon.new("ENC_%%.png", 15, 15, nil, CARotaryPB) -- dual encoder pushbutton

IconFlaps     = Icon.new({"H_FLAPS_0.png",  "H_FLAPS_10.png",  "H_FLAPS_20.png",  "H_FLAPS_30.png"}, 66, 152, nil, nil, Rectangle.new(-0,-51,66,50), Rectangle.new(0,51,66,50))
IconGust      = Icon.new({"H_GUST_OFF.png", "H_GUST_ON.png"}, 74, 167, nil, Rectangle.new(-25,0,50,167))
IconGear      = Icon.new({"H_GEAR_U.png",   "H_GEAR_D.png"},  25,  80, nil, Rectangle.new(0,0,80,80))
IconPBrake    = Icon.new({"H_PARK_OFF.png", "H_PARK_ON.png"}, 48, 196, nil, Rectangle.new(0,0,125,300))
IconManGear   = Icon.new({"H_MG_IN.png",    "H_MG_OUT.png"}, 196,  52, nil, Rectangle.new(0,0,200, 75))
IconPitchRot  = Icon.new({"H_PD_IN.png",    "H_PD_OUT.png"},  48, 120, nil, nil, Rectangle.new(-50,0,50,120), Rectangle.new(50,0,50,120))
IconPitchPull = Icon.new(nil, 50, 120)


txt_load_font("Segmental16.ttf")
FmcLineBl = SegmentType.new(TextField.new("Segmental16",  30, "CENTER",  "#00AAFF",  472, 24))
FmcLineWt = SegmentType.new(TextField.new("Segmental16",  30, "CENTER",  "#FFFFFF",  472, 24))

-- ************************************************************************
-- ** CONTROLS 
-- ************************************************************************
C300Key        = KeyType.new(IconKey)
C300LedRnd     = LEDType.new(IconLedRnd, {threshold = .1})
C300LedBar     = LEDType.new(IconLedBar, {threshold = .1, keyword = "GREEN"})
C300LedFMC     = LEDType.new(IconLedFMC, {threshold = 32})

C300Page       = SwitchType.new(IconPage)

C300ToggleV    = SwitchType.new(IconToggleV, {maxval = 2})
C300ToggleH    = SwitchType.new(IconToggleH, {maxval = 2})
C300ToggleVM   = SwitchType.new(IconToggleV, {minval = -1, momentary =  {[-1] = 0, [1] = 0}})
C300ToggleHM   = SwitchType.new(IconToggleH, {minval = -1, momentary =  {[-1] = 0, [1] = 0}})

C300Switch45   = SwitchType.new(IconSwitch,   {angle = 45,    maxval = 2, keyword = "ARR", dial = false})
C300Switch30   = SwitchType.new(IconSwitch,   {angle = 30,    maxval = 2, keyword = "CIR", dial = false})
C300Outer      = SwitchType.new(IconSwitchO,  {angle = 30,    maxval = 2, keyword = "CIR", dial = false})
C300VolL       = SwitchType.new(IconVolumeL,  {angle = 13.5,              step = -.05, dial = true, interval = 100 })
C300VolS       = SwitchType.new(IconVolumeS,  {angle = 13.5,              step = -.05, dial = true, interval = 100 })
C300Bright     = SwitchType.new(IconSwitch,   {angle = 19.25, minval =.3, step =  .05, dial = true, interval = 100, keyword = "CIR"})
C300Temp       = SwitchType.new(IconSwitch,   {angle = 13.5,  minval =-1, step =  .1,  dial = true, interval = 100, keyword = "CIR"})

C300EncoderO   = EncoderType.new(IconEncoderO,   {angle = 12, maxval = 30, cycle = true, interval = 100})
C300EncoderI   = EncoderType.new(IconEncoderI,   {angle = 12, maxval = 30, cycle = true, interval = 100})
C300EncoderW   = EncoderType.new(IconEncoderW,   {angle = 12, maxval = 4,  cycle = true, interval = 100})
C300EncoderPS  = KeyType.new(IconEncoderPS)
C300EncoderPD  = KeyType.new(IconEncoderPD)

-- Special controls: 
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

function addKeyF(x, y, ref, val, opts) -- fixed value key
    if opts == nil then opts = {} end
    opts.minval = val
    opts.maxval = val
    PANEL:add(x,y, C300Key:createInstance(ref, opts))
end

function addMfdK(x, y, baseref, opts) -- special mfd key
    PANEL:add(x, y, C300MfdKey:createInstance({XInt(baseref .. "_l"), XInt(baseref .. "_r")}, opts))
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

-- ###### Other Elements #########################################################################################
function addElem(x, y, ref, et, opt) 
    PANEL:add(x,y, et:createInstance(ref, opt))
end    

-- ************************************************************************
-- ** PANEL TYPES
-- ************************************************************************
local PD = PanelType.new("BASE_%%.png",true)
--local PZ = PanelType.new("BASE %%.png",false):addZoomedPane(2,true):addZoomedShadow("SHADOW %%.png", 14)

-- ************************************************************************
-- ** PAGES
-- ************************************************************************
img_add_fullscreen("BG_GREY.png")

local MAIN  = Page.new("MAIN", nil, nil, true)
local POPUP = {}
local FMC   = Page.new("FMC",   POPUP, "PAGE_GREY.png", false, Rectangle.new(1152, 152, 768, 888))
local UPPER = Page.new("UPPER", POPUP, "PAGE_GREY.png", false, Rectangle.new(1152, 152, 768, 888))
local LOWER = Page.new("LOWER", POPUP, "PAGE_GREY.png", false, Rectangle.new(1152, 152, 768, 888))

-- ************************************************************************
-- ** MAIN
-- ************************************************************************
PANEL = MAIN:add(PD:createInstance("BARO", -0, -0, 368, 152))
addEncS( 76, 84, XCmd("sim/instruments/barometer_up", "sim/instruments/barometer_down"), XCmd("sim/instruments/barometer_2992"), "RG", "BARO")
addPbaS(148, 84, XInt("cl300/comps_head_l_h"),  "DG")
addTglS(220, 84, XInt("cl300/comps_slew_l_sw"), false, true)
addTglS(292, 84, XInt("cl300/rudd_ped_l_sw"),   true,  true)

PANEL = MAIN:add(PD:createInstance("WARN", -368, -0, 100, 152))
addElem(50, 76, {CLEAR_ALERTS, XFlt("cl300/mast_caut"), XFlt("cl300/mast_warn")}, C300PBAL,
                {{momentary = {0}}, {keyword = "MC"}, {keyword = "MW"}})

PANEL = MAIN:add(PD:createInstance("DCP", -468, -0, 608, 152))
addEncD( 64, 108, XCmd("xap/DCP/dcp_tune_right_coarse", "xap/DCP/dcp_tune_left_coarse"), 
                  XCmd("xap/DCP/dcp_tune_right_fine", "xap/DCP/dcp_tune_left_fine"), 
                  XCmd("xap/DCP/dcp_tune_stb"), "FN", "TUNE", {angle = 24}, {angle = 24})

addEncD(304, 108, XCmd("xap/DCP/dcp_menu_right", "xap/DCP/dcp_menu_left"), 
                  XCmd("xap/DCP/dcp_data_right", "xap/DCP/dcp_data_left"), 
                  XCmd("xap/DCP/dcp_data_sel"), "RG", "MENU", {angle = 24}, {angle = 24})

addEncD(544, 108, XInt("cl300/dcp_tilt"), XInt("cl300/dcp_range"), XInt("sim/cockpit2/EFIS/map_range"), "RG", "MENU",
                  {angle = 30, maxval = 1500, minval = -1500}, {angle = 30, maxval = 1500, minval = -1500}, {maxval = 2, minval = 2})

addKeyP( 64,  44, XInt("cl300/dcp_1_2"))
addKeyP(144,  44, XInt("cl300/dcp_dmeh"))
addKeyP(144, 108, XInt("cl300/mfd_sel_state"))
addKeyC(224,  44, XInt("cl300/dcp_navsrc"),    3)
addKeyF(224, 108, XInt("cl300/autop_brgsrc"),  0)
addKeyC(384,  44, XInt("sim/cockpit2/EFIS/map_mode"), 5)
addKeyP(384, 108, XCmd("cl300/DCP/dcp_refs_button"))
addKeyP(464,  44, XInt("sim/cockpit2/EFIS/EFIS_tcas_on"))
addKeyP(464, 108, XInt("cl300/dcp_radar"))
addKeyP(544,  44, XInt("sim/cockpit2/EFIS/EFIS_weather_on"))

PANEL = MAIN:add(PD:createInstance("MCP", -1076, -0, 844, 152))
--addEncS( 60, 108, XCmd("sim/radios/obs_HSI_up",     "sim/radios/obs_HSI_down"),     XInt("cl300/crc_butt"),  "FN", "CRS")
--addEncS(220, 108, XCmd("sim/autopilot/heading_up",  "sim/autopilot/heading_down"),  XInt("cl300/fgp_s_hdg"), "RG", "HDG")
--addEncS(380, 108, XCmd("sim/autopilot/airspeed_up", "sim/autopilot/airspeed_down"), XInt("sim/cockpit2/autopilot/airspeed_is_mach"), "FN", "SPD")
--addEncS(620, 108, XCmd("sim/autopilot/altitude_up", "sim/autopilot/altitude_down"), CANCEL_ALT_ALERT, "FN", "ALT")
addEncS( 60, 108, CRS_DIAL, XInt("cl300/crc_butt"),  "FN", "CRS")
addEncS(220, 108, HDG_DIAL, XInt("cl300/fgp_s_hdg"), "RG", "HDG")
addEncS(380, 108, SPD_DIAL, XCmd("sim/autopilot/knots_mach_toggle"), "FN", "SPD")
addEncS(620, 108, ALT_DIAL, CANCEL_ALT_ALERT, "FN", "ALT")
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

PANEL = MAIN:add(PD:createInstance("MFD", -0, -976, 564, 104))
addTglS(516, 53, XInt("cl300/mfdpan_lr_sw"), false, false, {maxval=1})
C300MfdKey.selectingInst = PANEL:last()
addMfdK( 48, 28, "cl300/mfd_frmt", {minval = 0, maxval = 6, step = 1, cycle = true})
addMfdK( 48, 76, "cl300/mfd_antice")
addKeyP( 96, 28, XInt("sim/cockpit2/EFIS/EFIS_tcas_on"))
addMfdK( 96, 76, "cl300/mfd_ecs")
addKeyP(144, 28, XInt("sim/cockpit2/EFIS/EFIS_weather_on"))
addMfdK(144, 76, "cl300/mfd_electr")
addMfdK(192, 76, "cl300/mfd_flt_ctr")
addKeyP(216, 28, XInt("cl300/mfd_pan_cas"))
addMfdK(240, 76, "cl300/mfd_fuel")
addMfdK(288, 28, "cl300/mfd_sumry")
addMfdK(288, 76, "cl300/mfd_hydr")

addMfdK(336, 76, "cl300/mfd_checkl")
addKeyP(360, 28, XCmd("cl300/chklist_enter"),  {momentary = {0}})
addKeyP(384, 76, XCmd("cl300/chklist_skip"),   {momentary = {0}})
addKeyP(429, 52, XCmd("cl300/chklist_jleft"),  {momentary = {0}})
addKeyP(468, 52, XCmd("cl300/chklist_jright"), {momentary = {0}})

PANEL = MAIN:add(PD:createInstance("CLK", -564, -976, 104, 104))
addKeyP(30, 32, XInt("cl300/clock_flt"))
addKeyC(30, 72, XInt("cl300/clock_timer_h"), 3)
addKeyP(74, 32, XInt("cl300/clock_gps"))
addKeyC(74, 72, XInt("cl300/clock_mode"), 3)

PANEL = MAIN:add(PD:createInstance("TAWS", -668, -976, 256, 104))
addCPbS( 56, 64, XInt("cl300/taws_gs_h"),  "OFF","CLR")
addCPbS(128, 64, XInt("cl300/taws_flp_h"), "OFF","CLR")
addCPbS(200, 64, XInt("cl300/taws_ter_h"), "OFF","CLR")

PANEL = MAIN:add(PD:createInstance("GEAR", -924, -976, 228, 104))
addPbaS( 56, 64, XInt("cl300/nws_h"), "OFF")
addElem(124, 60, XInt("sim/cockpit2/controls/gear_handle_down"), SwitchType.new(IconGear))

PANEL = MAIN:add(PD:createInstance("PAGES", -1171, -1047, 730, 33))
addElem(117, 16, AInt("PAGES/FMC_SHOW"),   C300Page, {keyword = "FMC"})
addElem(365, 16, AInt("PAGES/UPPER_SHOW"), C300Page, {keyword = "UPPER"})
addElem(613, 16, AInt("PAGES/LOWER_SHOW"), C300Page, {keyword = "LOWER"})

-- ************************************************************************
-- ** FMC
-- ************************************************************************
PANEL = FMC:add(PD:createInstance("FMC",-16,-16,736,872))
addElem(368,  76, AStr("fmc/lines/lg_1", 30), FmcLineBl)
addElem(368,  76, AStr("fmc/lines/sm_1", 30), FmcLineWt)
addElem(368, 110, AStr("fmc/lines/lg_2", 30), FmcLineBl)
addElem(368, 110, AStr("fmc/lines/sm_2", 30), FmcLineWt)
addElem(368, 134, AStr("fmc/lines/lg_3", 30), FmcLineBl)
addElem(368, 134, AStr("fmc/lines/sm_3", 30), FmcLineWt)
addElem(368, 162, AStr("fmc/lines/lg_4", 30), FmcLineBl)
addElem(368, 162, AStr("fmc/lines/sm_4", 30), FmcLineWt)
addElem(368, 186, AStr("fmc/lines/lg_5", 30), FmcLineBl)
addElem(368, 186, AStr("fmc/lines/sm_5", 30), FmcLineWt)
addElem(368, 214, AStr("fmc/lines/lg_6", 30), FmcLineBl)
addElem(368, 214, AStr("fmc/lines/sm_6", 30), FmcLineWt)
addElem(368, 238, AStr("fmc/lines/lg_7", 30), FmcLineBl)
addElem(368, 238, AStr("fmc/lines/sm_7", 30), FmcLineWt)
addElem(368, 266, AStr("fmc/lines/lg_8", 30), FmcLineBl)
addElem(368, 266, AStr("fmc/lines/sm_8", 30), FmcLineWt)
addElem(368, 290, AStr("fmc/lines/lg_9", 30), FmcLineBl)
addElem(368, 290, AStr("fmc/lines/sm_9", 30), FmcLineWt)
addElem(368, 318, AStr("fmc/lines/lg_10", 30), FmcLineBl)
addElem(368, 318, AStr("fmc/lines/sm_10", 30), FmcLineWt)
addElem(368, 342, AStr("fmc/lines/lg_11", 30), FmcLineBl)
addElem(368, 342, AStr("fmc/lines/sm_11", 30), FmcLineWt)
addElem(368, 370, AStr("fmc/lines/lg_12", 30), FmcLineBl)
addElem(368, 370, AStr("fmc/lines/sm_12", 30), FmcLineWt)
addElem(368, 394, AStr("fmc/lines/lg_13", 30), FmcLineBl)
addElem(368, 394, AStr("fmc/lines/sm_13", 30), FmcLineWt)
addElem(368, 428, AStr("fmc/lines/lg_14", 30), FmcLineBl)
addElem(368, 428, AStr("fmc/lines/sm_14", 30), FmcLineWt)

addElem(656, 452, XInt("xfmc/Status"), C300LedFMC)

addKeyF( 56, 124, XInt("xfmc/Keypath"),  0)
addKeyF( 56, 176, XInt("xfmc/Keypath"),  1)
addKeyF( 56, 228, XInt("xfmc/Keypath"),  2)
addKeyF( 56, 280, XInt("xfmc/Keypath"),  3)
addKeyF( 56, 332, XInt("xfmc/Keypath"),  4)
addKeyF( 56, 384, XInt("xfmc/Keypath"),  5)
addKeyF(680, 124, XInt("xfmc/Keypath"),  6)
addKeyF(680, 176, XInt("xfmc/Keypath"),  7)
addKeyF(680, 228, XInt("xfmc/Keypath"),  8)
addKeyF(680, 280, XInt("xfmc/Keypath"),  9)
addKeyF(680, 332, XInt("xfmc/Keypath"), 10)
addKeyF(680, 384, XInt("xfmc/Keypath"), 11)

-- ************************************************************************
-- ** UPPER
-- ************************************************************************
PANEL = UPPER:add(PD:createInstance("FUEL",-16,-16,368,176))
addPbaS(184,  60, XInt("cl300/fuel_xflow_up_h"), "BAR")
addPbaS(184, 136, XInt("cl300/fuel_xflow_dn_h"), "BAR")
addSw45( 76, 144, XInt("cl300/fuel_xpump_l"))
addSw45(292, 144, XInt("cl300/fuel_xpump_r"))

PANEL = UPPER:add(PD:createInstance("AUDIO",-16,-192, 368,200)) 
addElem( 64,  28, XFlt("cl300/aud_com1_l"), C300LedBar)
addElem(104,  28, XFlt("cl300/aud_com2_l"), C300LedBar)
addElem(144,  28, XFlt("cl300/aud_com3_l"), C300LedBar)
addElem(184,  28, XFlt("cl300/aud_hf1_l"),  C300LedBar)
addElem(224,  28, XFlt("cl300/aud_hf2_l"),  C300LedBar)
addElem(264,  28, XFlt("cl300/aud_cab_l"),  C300LedBar)
addElem(304,  28, XFlt("cl300/aud_pa_l"),   C300LedBar)

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


PANEL = UPPER:add(PD:createInstance("INT",-16,-392,368,176))
addSw45( 76,  60, XFlt("cl300/annun_h"),   nil, {angle = 60, maxval=1, center=.5})
addRBrt(184,  60, {XFlt("cl300/cmfd_h"),   XFlt("cl300/cpfd_h"), XFlt("cl300/pmfd_h"), XFlt("cl300/ppfd_h")})
addRBrt(292,  60, {XFlt("cl300/gshldl_h"), XFlt("cl300/gshldr_h")})
addRBrt( 76, 136, XFlt("cl300/dome_h"))
addRBrt(184, 136, XFlt("cl300/pedestal_h"))
addRBrt(292, 136, XFlt("cl300/cbp_h"))

PANEL = UPPER:add(PD:createInstance("EXT",-16,-568,368,176))
addTglS( 76,  60, XFlt("cl300/wing_insp_h"),     true, false, {maxval=1})
addTglS(148,  60, XFlt("cl300/nav_h"),           true, false)
addTglS(220,  60, XFlt("cl300/strobe_h"),        true, false)
addTglS(292,  60, XInt("cl300/smokebelts_h"),    true, false)
addTglS( 76, 136, XFlt("cl300/emeright_h"),      true, false)
addTglS(148, 136, XFlt("cl300/landlight1_h"),    true, false, {maxval=1})
addTglS(220, 136, XFlt("cl300/xap_taxilight_h"), true, false)
addTglS(292, 136, XFlt("cl300/landlight2_h"),    true, false, {maxval=1})

PANEL = UPPER:add(PD:createInstance("DISPL",-16,-744,368,144))
addSw30( 68,  56, XInt("cl300/rev_pan_l"))
addSw30(184,  56, XInt("cl300/rev_tune"), nil, {maxval=3,center=2})
addSw30(300,  56, XInt("cl300/rev_pan_r"))
addSw30(124, 112, XInt("cl300/rev_att_hd"))
addSw30(228, 112, XInt("cl300/rev_air_dat"))

PANEL = UPPER:add(PD:createInstance("PRESS",-384,-16,368,176))
addRTmp( 76,  60, XFlt("cl300/pressure_manrate"),     "ARR")
addPbaS(184,  60, XInt("cl300/pressure_man_h"),       "ON")
addCPbS( 76, 136, XInt("cl300/pressure_emer_depr_h"), "ON", "RED")
addCPbS(184, 136, XInt("cl300/pressure_ditch_h"),     "ON", "RED")
addElem(292, 116, XInt("cl300/pressure_lndg_alt_1"),  C300Outer, {keyword = "OUT"})
addElem(292, 116, XFlt("cl300/pressure_lndg_alt_2"), 
                  EncoderType.new(IconEncoderI, {keyword = "RG", angle = 15, minval = -1, step  = .01, cycle = false, interval = 25,  tics = 50}))

PANEL = UPPER:add(PD:createInstance("AC",-384,-192,368,252))
addRTmp( 76,  60, XFlt("cl300/aircond_cockpit_temp"))
addRTmp(292,  60, XFlt("cl300/aircond_cabin_temp"))
addPbaS(184,  60, XInt("cl300/aircond_man_temp_h"), "ON")
addCPbS( 76, 136, XInt("cl300/aircond_ramair_h"),   "ON", "CLR")
addSw45(184, 144, XInt("cl300/aircond_airsource"),  nil, {maxval=3,center=1})
addPbaS(292, 136, XInt("cl300/bleed_apu_h"),        "ON")
addPbaS( 76, 212, XInt("cl300/bleed_en_l_h"),       "OFF")
addPbaS(184, 212, XInt("cl300/bleed_xbleed_h"),     "BAR")
addPbaS(292, 212, XInt("cl300/bleed_en_r_h"),       "OFF")

PANEL = UPPER:add(PD:createInstance("ICE",-384,-444,368,176))
addSw45( 76,  68, XInt("cl300/antice_wngsource_r"))
addPbaS(148,  60, XInt("cl300/antice_wing_h"),    "ON")
addPbaS(220,  60, XInt("cl300/antice_probe_l_h"), "OFF")
addPbaS(292,  60, XInt("cl300/antice_probe_r_h"), "OFF")
addPbaS( 76, 136, XInt("cl300/antice_engn_l_h"),  "ON")
addPbaS(148, 136, XInt("cl300/antice_engn_r_h"),  "ON")
addPbaS(220, 136, XInt("cl300/antice_wshld_l_h"), "OFF")
addPbaS(292, 136, XInt("cl300/antice_wshld_r_h"), "OFF")

PANEL = UPPER:add(PD:createInstance("ELEC",-384,-620,368,268))
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
PANEL = LOWER:add(PD:createInstance("RUN",-244,-16,280,84))
addTglS( 88,  44, XInt("cl300/en_but_run_l"), true, false, {maxval=1})
addTglS(192,  44, XInt("cl300/en_but_run_r"), true, false, {maxval=1})

PANEL = LOWER:add(PD:createInstance("SPLRS",-244,-100,280,88))
addSw45( 88,  56, XInt("cl300/ground_sp_h"))
addCPbS(192,  48, XFlt("cl300/flight_spoil_h"), "OFF","RED")

PANEL = LOWER:add(PD:createInstance("FLAPS",-524,-16,228,172))
addElem(130,  87, XFlt("sim/cockpit2/controls/flap_ratio"), SwitchType.new(IconFlaps, {step = 0.33333333}))

-- create pitch disc /gust lock after the central panels because it will overlap the other panels
PANEL = LOWER:add(PD:createInstance("GUST",-16,-16,228,172))
PANEL:add( 88, 86, C300PitchDisc:createInstance(XInt("cl300/pitch_d_2")))
PANEL:add( 88, 86, C300PitchPull:createInstance(XInt("cl300/pitch_d_1"), PANEL:last()))
addElem(  219, 84, XInt("cl300/gust_lock"), SwitchType.new(IconGust))

PANEL = LOWER:add(PD:createInstance("TRIM",-16,-188,120,344))
addElem( 60,  60, XFlt("cl300/trim_rud"), 
                  SwitchType.new(IconSwitch, {angle=2.7, minval=-1, step=.02, dial=true, interval=25, tics=50, keyword="DIA"}))
addSw45( 60, 140, XInt("cl300/trim_stab"), nil, {center = 0})
addCPbS( 60, 212, XInt("cl300/trim_pusher_h"), "OFF","RED")

PANEL = LOWER:add(PD:createInstance("PARK",-136,-188,248,248))
addElem(124, 122, XFlt("sim/cockpit2/controls/parking_brake_ratio"), SwitchType.new(IconPBrake))

PANEL = LOWER:add(PD:createInstance("TEST",-136,-436,248,96))
addElem(124,  56, XInt("cl300/test_rot"), C300Outer, {maxval = 7, center = 0, angle = 36, keyword = "ARR"})
addKeyM(124,  56, XInt("cl300/test_push"))

PANEL = LOWER:add(PD:createInstance("ELT",-16,-532,368,156))
addElem(220,  52, XFlt("cl300/elt"),   C300LedRnd, {keyword = "RED"})
addTglS(292,  52, XInt("cl300/elt_h"), true, false, {maxval  = 1})
addKeyM( 76, 112, XInt("cl300/voice_rec_test"))
addElem(147, 112, XInt("cl300/voice_rec_test_lt"), C300LedRnd, {keyword = "GREEN"})

PANEL = LOWER:add(PD:createInstance("CAB",-16,-688,368,100))
addCPbS( 76,  60, XInt("cl300/cab_dc_h"), "OFF","CLR")
addCPbS(148,  60, XInt("cl300/cab_ac_h"), "OFF","CLR")
addPbaS(220,  60, XFlt("cl300/cablight_h"), "ON")
addPbaS(292,  60, XFlt("cl300/entrlight_h"), "ON")

PANEL = LOWER:add(PD:createInstance("AW",-16,-788,368,100))
addCPbS(112,  60, XInt("cl300/dcu_a_h"), "OFF","CLR")
addCPbS(256,  60, XInt("cl300/dcu_b_h"), "OFF","CLR")

PANEL = LOWER:add(PD:createInstance("HYDR",-384,-188,368,176))
addCPbS( 76,  60, XInt("cl300/hydr_l_sov_h"), "CLOSED","CLR", {inverted = true})
addSw45(148,  68, XInt("cl300/l_hpump_h"))
addSw45(220,  68, XInt("cl300/r_hpump_h"))
addCPbS(292,  60, XInt("cl300/hydr_r_sov_h"), "CLOSED","CLR", {inverted = true})
addCPbS( 76, 136, XInt("cl300/hydr_altn_flp_h"), "ON",    "CLR")
addSw45(184, 144, XInt("cl300/ptu_h"), "DIA")
addSw45(292, 144, XInt("cl300/aux_hpump_h"), nil, nil, {maxval = 1, center = 1})

PANEL = LOWER:add(PD:createInstance("ENG",-384,-364,368,324))
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

PANEL = LOWER:add(PD:createInstance("APU",-384,-688,368,100))
addSw45( 64,  68, XInt("sim/cockpit/engine/APU_switch"), nil, {momentary = {[2] = 1}})
addElem(248,  50, XInt("cl300/lg_man"), SwitchType.new(IconManGear))

PANEL = LOWER:add(PD:createInstance("OXY",-384,-788,368,100))
addCPbS(112,  60, XInt("cl300/oxigen_terap_h"), "OFF","CLR")
addSw45(256,  68, XInt("cl300/oxigen_ox"))




MAIN:deploy()
FMC:deploy()
UPPER:deploy()
LOWER:deploy()
