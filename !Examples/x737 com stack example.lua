-- This simulates the comm/nav stack on the Boeing 737
-- It uses standard X=plane datarefs except for the transponder.
-- Transponder mode datarf are adapted to work with XHSI for TCAS TA

-- EMPTY: Transparent image to be used for the invisible buttons.
EMPTY = "blank.png"
-- ** Uncomment the next line to enable the red overlays to show the clickable areas:
--EMPTY = "blank_red.png"

-- NOCURSER: You can use this variably to override all cursors with a single graphic
-- Note that you cannot use a completely transparent image as cursor, therefore use a 
-- grey pixel/rectangle with 1% opacity if you want a invisible cursor
-- ** Uncomment the next line for transparent cursors if you use a touchscreen:
--NOCURSOR = "cursor_invisible.png"  

-- ALLOW_REVERSE: If this is set to true, the up/down button will move the switch in the 
-- opposite direction (down/up) if the switch is already at its end of its movement. 
ALLOW_REVERSE = true

-- CLASSIC_BUTTONS: If this is set to true, encoders and rotary switches will use the old button interface.
-- ** Uncomment the next line for 'classic' button interface:
--CLASSIC_BUTTONS = true

-- ZOOMABLE: If this is set to true, all panels except those with large handles
-- will be zoomable. 
-- ** Uncomment the next line for zoomable panels:
--ZOOMABLE = true

-- TRANSPONDER_MODE
-- X-Plane, xHSI and the x737 all use different values for the transponder mode dataref. With TRANSPONDER_MODE,
-- you can select the behavior you want: 
-- DEFAULT: TEST => TEST (3), STBY => STBY (1), ALT OFF/ON, TA, TA/RA => ON (2)
-- XHSI:    TEST => OFF (0),  STBY => STBY (1), ALT OFF/ON => XPDR (2), TA => TA (3), TA/RA => TA/RA (4)*    *currently XHSI doesn't recognize TA/RA correctly
-- X737:    TEST => TEST (4), STBY => STBY (0), ALT OFF/ON => XPDR (1), TA => TA (2), TA/RA => TA/RA (3)
local TRANSPONDER_MODE = "XHSI"

-- ************************************************************************
-- ** CURSORS
-- ************************************************************************
CursorTgl     = CursorSet.new("cursor_toggle.png")
CursorTglRot  = CursorSet.new("cursor_toggle_rot.png")
CursorRotCtr  = CursorSet.new(nil, "ctr_cursor_ccw.png",   "ctr_cursor_cw.png")
CursorRotSml  = CursorSet.new(nil, "small_cursor_ccw.png", "small_cursor_cw.png")
CursorRotLrg  = CursorSet.new(nil, "large_cursor_ccw.png", "large_cursor_cw.png")

-- ************************************************************************
-- ** FONTS, SOUNDS
-- ************************************************************************
txt_load_font("Segmental16.ttf")
txt_load_font("Segmental7.ttf")
TCAS_TEST = sound_add ( "tcas_test_okay.wav" )

-- ************************************************************************
-- ** BASIC GUI ELEMENTS 
-- ************************************************************************
ShadowLy = StaticType.new(Icon.new("shadows_%%.png",      700, 350))

-- Dials:
IconComI = Icon.new("upper_knob.png",  71,  71, CursorRotCtr, nil, Rectangle.new(-45, -45, 80, 80), Rectangle.new(45, -45, 80, 80))
IconComO = Icon.new("lower_knob.png", 121, 121, CursorRotLrg, nil, Rectangle.new(-45,  45, 80, 80), Rectangle.new(45,  45, 80, 80))
DialComI = EncoderType.new(IconComI, {angle =  6, maxval = 60, interval = 100})
DialComO = EncoderType.new(IconComO, {angle =  8, maxval = 45, interval = 200})
DialNavI = EncoderType.new(IconComI, {angle = 12, maxval = 30, interval = 200})
DialNavO = DialComO -- same settings

IconAdfI = Icon.new("upper_adf_knob.png",   50,  50, CursorRotCtr, nil, Rectangle.new(-45, -60, 80, 60), Rectangle.new(45, -60, 80, 60))
IconAdfM = Icon.new("middle_adf_knob.png",  90,  90, CursorRotSml, nil, Rectangle.new(-45,   0, 80, 60), Rectangle.new(45,   0, 80, 60))
IconAdfO = Icon.new("lower_adf_knob.png",  130, 130, CursorRotLrg, nil, Rectangle.new(-45,  60, 80, 60), Rectangle.new(45,  60, 80, 60))
DialAdfI = EncoderType.new(IconAdfI, {angle = 12, maxval = 10, interval = 200, digit = 1})
DialAdfM = EncoderType.new(IconAdfM, {angle =  8, maxval = 10, interval = 200, digit = 2})
DialAdfO = EncoderType.new(IconAdfO, {angle =  8, maxval = 10, interval = 200, digit = 3})

IconXpdI = Icon.new("xpdr_little_knob.png", 52,  52, CursorRotCtr, nil, Rectangle.new(-45, -45, 80, 80), Rectangle.new(45, -45, 80, 80))
IconXpdO = Icon.new("xpdr_big_knob.png",   102, 102, CursorRotLrg, nil, Rectangle.new(-45,  45, 80, 80), Rectangle.new(45,  45, 80, 80))
DialXpdI = EncoderType.new(IconXpdI, {angle = 10, maxval = 36, interval = 200})
DialXpdO = EncoderType.new(IconXpdO, {angle = 15, maxval = 24, interval = 200})

-- Buttons, Switches:
BtnTrans = SwitchType.new(Icon.new({"blank.png", "transfer_btn_in.png"},      80, 57), {momentary = {[1] = 0}})
BtnCNTst = SwitchType.new(Icon.new({"blank.png", "com_test_btn_in.png"},      81, 75), {momentary = {[1] = 0}})
BtnIdent = SwitchType.new(Icon.new({"ident_out.png","ident_in.png"},          41, 41), {momentary = {[1] = 0}})
SwAdfXfr = SwitchType.new(Icon.new({"txfr_left_sw.png", "txfr_right_sw.png"}, 74, 33,   CursorTgl))
SwAdfOn  = SwitchType.new(Icon.new({"knob_lt.png", "knob_rt.png"},            98, 98,   CursorTglRot))
SwXpdSys = SwitchType.new(Icon.new({"switchup_1.png", "switchdn_1.png"},      46, 54,   CursorTgl, Rectangle.new(0,0,50, 100)))
SwXpdMod = SwitchType.new(Icon.new({"tspdr8oc.png","tspdr10oc.png","tspdr11oc.png","tspdr1oc.png","tspdr2oc.png","tspdr4oc.png"}, 101, 101,     
                                    CursorRotSml, nil, Rectangle.new(-40, 0, 70, 100), Rectangle.new(40, 0, 70, 100)), {maxval = 5, dial = true})

-- LEDs:
AdfAntLed = LEDType.new(Icon.new({"blank.png", "ant_flag.png", "adf_flag.png"}, 45, 50), {threshold = {1,2}})
AdfSelLed = LEDType.new(Icon.new("txfr_lite.png", 25, 24), {threshold = 1})
XpdErrLed = LEDType.new(Icon.new("fail_lite.png", 25, 24), {threshold = 1, inverted = true})

-- Segment displays:
ComDispl = SegmentType.new(TextField.new("Segmental7",  65, "CENTER",  "white", 180, 50), {pattern = "%03d.%03d"})
NavDispl = SegmentType.new(TextField.new("Segmental7",  65, "CENTER",  "white", 180, 50), {pattern = "%03d.%02d"})
AdfDispl = SegmentType.new(TextField.new("Segmental7",  65, "CENTER",  "white",  90, 50), {pattern = "%03d"})
XpdCodeD = SegmentType.new(TextField.new("Segmental7",  65, "CENTER",  "white", 120, 50))
XpdSystD = SegmentType.new(TextField.new("Segmental16", 40, "CENTER",  "white", 180, 30))

-- ************************************************************************
-- ** FUNCTIONS, COMMANDS, DATAREFS
-- ************************************************************************
local PWR = { BUS   = AInt("am/x737/avionics_powered"),
              BAT   = XInt("sim/cockpit/electrical/battery_on"),
              GEN   = XInt("sim/cockpit2/electrical/generator_on", 1, 8),
              AVI   = XInt("sim/cockpit2/switches/avionics_power_on")}

-- Connect BAT, GEN and AVI to single internal dataref BUS:
PWR.logic = Logic.new({PWR.BUS, PWR.BAT, PWR.GEN, PWR.AVI}, function(self, valpos) if valpos > 1 then self:write(1, ((self.values[2] > 0 or self.values[3] > 0) and self.values[4] > 0) and 1 or 0) end end)

function radioRefs(kind)
    return { ON     = XInt("sim/cockpit2/radios/actuators/"..kind.."_power"),
             TEST   = AInt("am/x737/"..kind.."_test"), 
             FLIP   = XCmd("sim/radios/"..kind.."_standy_flip"),
             COARSE = XCmd("sim/radios/stby_"..kind.."_coarse_up", "sim/radios/stby_"..kind.."_coarse_down"),
             FINE   = XCmd("sim/radios/stby_"..kind.."_fine_up",   "sim/radios/stby_"..kind.."_fine_down"),
             FREQ   = {XInt("sim/cockpit2/radios/actuators/"..kind.."_frequency_Mhz"),         XInt("sim/cockpit2/radios/actuators/"..kind.."_frequency_khz")},
             STBY   = {XInt("sim/cockpit2/radios/actuators/"..kind.."_standby_frequency_Mhz"), XInt("sim/cockpit2/radios/actuators/"..kind.."_standby_frequency_khz")}}
end

local COM1 = radioRefs("com1")
local COM2 = radioRefs("com2")
local NAV1 = radioRefs("nav1")
local NAV2 = radioRefs("nav2")

function adfRefs(kind)
    return { ON     = XInt("sim/cockpit2/radios/actuators/"..kind.."_power"),
             SEL    = XInt("sim/cockpit2/radios/actuators/"..kind.."_right_is_selected"),
             LEFT   = XInt("sim/cockpit2/radios/actuators/"..kind.."_left_frequency_hz"),
             RIGHT  = XInt("sim/cockpit2/radios/actuators/"..kind.."_right_frequency_hz"),
             ANT    = AInt("am/x737/"..kind.."_ant_or_adf"),
             ON_SW  = AInt("am/x737/"..kind.."_on_switch")}
end

local ADF1 = adfRefs("adf1")

local XPDR = { KNOB  = AInt("am/x737/transponder_mode"), 
               SYS   = AInt("am/x737/transponder_system"), 
               ALT   = AInt("am/x737/transponder_altsrc"),
               MODE  = XInt("sim/cockpit2/radios/actuators/transponder_mode"), 
               CODE  = XInt("sim/cockpit2/radios/actuators/transponder_code"),
               ONES  = XCmd("sim/transponder/transponder_ones_up", "sim/transponder/transponder_ones_down"),
               TENS  = XCmd("sim/transponder/transponder_tens_up", "sim/transponder/transponder_tens_down"),
               HUNDS = XCmd("sim/transponder/transponder_hundreds_up", "sim/transponder/transponder_hundreds_down"),
               THOUS = XCmd("sim/transponder/transponder_thousands_up", "sim/transponder/transponder_thousands_down")}

-- ************************************************************************
-- ** COM STACK
-- ************************************************************************
local panel
local PNL = (ZOOMABLE and PanelType.new("bg_%%.png",false):addZoomedPane(2,true, CursorZoom) or PanelType.new("bg_%%.png",true))
local COMSTACK = Page.new(nil, true)

-- COM 1 -------------------------------------------------------------------
panel = COMSTACK:add(PNL:createInstance("com",   0,    0,700,350))
panel:add(602, 266, DialComO:createInstance(COM1.COARSE))
panel:add(350, 175, ShadowLy:createInstance({keyword="lower_com"}))
panel:add(602, 266, DialComI:createInstance(COM1.FINE))
panel:add(350, 112, BtnTrans:createInstance(COM1.FLIP))
panel:add(350, 267, BtnCNTst:createInstance(COM1.TEST))
panel:add(190, 105, ComDispl:createInstance(COM1.FREQ))
panel:add(510, 105, ComDispl:createInstance(COM1.STBY))
DynamicBus.new("com1pwr", {PWR.BUS, COM1.ON}):addPanel(panel):update()

-- COM 2 -------------------------------------------------------------------
panel = COMSTACK:add(PNL:createInstance("com",-700,    0,700,350))
panel:add(602, 266, DialComO:createInstance(COM2.COARSE))
panel:add(350, 175, ShadowLy:createInstance({keyword="lower_com"}))
panel:add(602, 266, DialComI:createInstance(COM2.FINE))
panel:add(350, 112, BtnTrans:createInstance(COM2.FLIP))
panel:add(350, 267, BtnCNTst:createInstance(COM2.TEST))
panel:add(190, 105, ComDispl:createInstance(COM2.FREQ))
panel:add(510, 105, ComDispl:createInstance(COM2.STBY))
DynamicBus.new("com2pwr", {PWR.BUS, COM2.ON}):addPanel(panel):update()

-- NAV 1 -------------------------------------------------------------------
panel = COMSTACK:add(PNL:createInstance("nav",   0, -350,700,350))
panel:add(602, 266, DialNavO:createInstance(NAV1.COARSE))
panel:add(350, 175, ShadowLy:createInstance({keyword="lower_nav"}))
panel:add(602, 266, DialNavI:createInstance(NAV1.FINE))
panel:add(350, 112, BtnTrans:createInstance(NAV1.FLIP))
panel:add(147, 260, BtnCNTst:createInstance(NAV1.TEST))
panel:add(190, 105, NavDispl:createInstance(NAV1.FREQ))
panel:add(510, 105, NavDispl:createInstance(NAV1.STBY))
DynamicBus.new("nav1pwr", {PWR.BUS, NAV1.ON}):addPanel(panel):update()

-- NAV 2 -------------------------------------------------------------------
panel = COMSTACK:add(PNL:createInstance("nav",-700, -350,700,350))
panel:add(602, 266, DialNavO:createInstance(NAV2.COARSE))
panel:add(350, 175, ShadowLy:createInstance({keyword="lower_nav"}))
panel:add(602, 266, DialNavI:createInstance(NAV2.FINE))
panel:add(350, 112, BtnTrans:createInstance(NAV2.FLIP))
panel:add(147, 260, BtnCNTst:createInstance(NAV2.TEST))
panel:add(190, 105, NavDispl:createInstance(NAV2.FREQ))
panel:add(510, 105, NavDispl:createInstance(NAV2.STBY))
DynamicBus.new("nav2pwr", {PWR.BUS, NAV2.ON}):addPanel(panel):update()

-- ADF 1 -------------------------------------------------------------------
panel = COMSTACK:add(PNL:createInstance("adf",   0, -700,700,350))
panel:add(135, 244, DialAdfO:createInstance(ADF1.LEFT))
panel:add(566, 244, DialAdfO:createInstance(ADF1.RIGHT))
panel:add(350, 175, ShadowLy:createInstance({keyword="lower_adf"}))
panel:add(135, 244, DialAdfM:createInstance(ADF1.LEFT))
panel:add(566, 244, DialAdfM:createInstance(ADF1.RIGHT))
panel:add(350, 175, ShadowLy:createInstance({keyword="upper_adf"}))
panel:add(135, 244, DialAdfI:createInstance(ADF1.LEFT))
panel:add(566, 244, DialAdfI:createInstance(ADF1.RIGHT))
panel:add(220, 108, AdfDispl:createInstance(ADF1.LEFT))
panel:add(540, 108, AdfDispl:createInstance(ADF1.RIGHT))
panel:add(200,  47, AdfSelLed:createInstance(ADF1.SEL, {inverted = true}))
panel:add(508,  47, AdfSelLed:createInstance(ADF1.SEL))
panel:add(115, 110, AdfAntLed:createInstance(ADF1.ON))
panel:add(435, 110, AdfAntLed:createInstance(ADF1.ON))
DynamicBus.new("adf1pwr", {PWR.BUS, ADF1.ON}):addPanel(panel):update()

-- Switches not linked to bus power:
panel:add(348, 111, SwAdfXfr:createInstance(ADF1.SEL))
panel:add(268, 241, SwAdfOn:createInstance(ADF1.ANT))
panel:add(447, 241, SwAdfOn:createInstance(ADF1.ON_SW))

-- Link ADF1.ANT and ADF1.ON_SW to ADF1.ON
local ADF_LOGIC = Logic.new({ADF1.ON, ADF1.ON_SW, ADF1.ANT}, 
    function(self, valpos, newval, oldval) 
        if valpos == 1 then -- XP changed
            self:write(2, newval > 0 and 1 or 0)
            if newval > 0 then
                self:write(3, 2 - newval)
            end
        else -- Knob turned
            self:write(1, self.values[2] > 0 and 2 - self.values[3] or 0)
        end
    end)

panel = COMSTACK:add(PNL:createInstance("xpdr",-700, -700,700,350))

panel:add(231, 265, DialXpdO:createInstance(XPDR.THOUS))
panel:add(455, 265, DialXpdO:createInstance(XPDR.TENS))
panel:add(350, 175, ShadowLy:createInstance({keyword="lower_xpdr"}))
panel:add(231, 265, DialXpdI:createInstance(XPDR.HUNDS))
panel:add(455, 265, DialXpdI:createInstance(XPDR.ONES))
panel:add(602, 100, XpdErrLed:createInstance(XPDR.KNOB))
panel:add(450, 120, XpdCodeD:createInstance({XPDR.CODE, XPDR.KNOB}, {custom = function(code, mode) if mode == 0 then return "8888" else return string.format("%04d", code) end end }))
panel:add(450,  67, XpdSystD:createInstance({XPDR.SYS,  XPDR.KNOB}, {custom = function(sys, mode) if mode == 0 then return "ATC1  ATC2" elseif sys == 0 then return "ATC1     " else return "     ATC2" end end}))
DynamicBus.new("xpdrpwr", PWR.BUS):addPanel(panel):update()

-- second bus, mode >= 2
panel:add(352, 268, BtnIdent:createInstance(XCmd("sim/transponder/transponder_ident")))
DynamicBus.new("xpdrpwr_on", {PWR.BUS, XPDR.KNOB}, {1,2}):addItem(panel:last()):update()

-- Switches not linked to bus power:
panel:add(179, 104, SwXpdMod:createInstance(XPDR.KNOB, {updateCallback = function(inst) if inst:getValue() == 0 then sound_play(TCAS_TEST) end end}))
panel:add(112, 267, SwXpdSys:createInstance(XPDR.SYS))
panel:add(587, 267, SwXpdSys:createInstance(XPDR.ALT))

-- Link XPDR.KNOB to XPDR.MODE
local TRANSPONDER_MODE_MAP = { FROM_XP = nil, FROM_AM = nil }
if TRANSPONDER_MODE == "XHSI" then
    TRANSPONDER_MODE_MAP.FROM_XP = {[0] = 0, 1, 3, 4, 5}    -- OFF/0 => TEST, STBY/1 => STBY, XPDR/2 => ALT ON, TA => TA, (TARA => TARA) -- note: TARA currently not recognized by XHSI
    TRANSPONDER_MODE_MAP.FROM_AM = {[0] = 0, 1, 2, 2, 3, 4} -- TEST => OFF, STBY => STBY, ALT ON/OFF => XPDR, TA => TA, (TARA => TARA)
elseif TRANSPONDER_MODE == "X737" then
    TRANSPONDER_MODE_MAP.FROM_XP = {[0] = 1, 3, 4, 5, 0}    -- STBY/0 => STBY, XPDR/1 => ALT ON, TA/2 => TA, TARA/3 => TARA, TEST/4 => TEST
    TRANSPONDER_MODE_MAP.FROM_AM = {[0] = 4, 0, 1, 1, 2, 3} -- TEST => TEST, STBY => STBY, ALT OFF/ON => XPDR, TA => TA, TARA => TARA
else
    TRANSPONDER_MODE_MAP.FROM_XP = {[0] = 0, 1, 3, 0, 0}    -- OFF/0 & TEST/3+ => TEST, STBY/1 => STBY, ON/2 => ALT ON
    TRANSPONDER_MODE_MAP.FROM_AM = {[0] = 3, 1, 2, 2, 2, 2} -- TEST => TEST, STBY => STBY, all other => ON
end

local XPDR_LOGIC = Logic.new({XPDR.MODE, XPDR.KNOB}, 
    function(self, valpos, newval, oldval) 
        if valpos == 1 then -- XP changed
            self:write(2, TRANSPONDER_MODE_MAP.FROM_XP[newval])
        else -- Knob Turned
            self:write(1, TRANSPONDER_MODE_MAP.FROM_AM[newval])
        end
    end)

COMSTACK:deploy()
