PAGE = Page.new("cl300/mfd_fuel_" .. SIDE, "FUEL.png", 0, 412, 670, 392)

local tfuelLBS_SUM  = Text.new("7000",    TXT_12B_R, {"#00FF00","#FFFF00","#FF0000"},     95, 463, 40, 12, tCONST)
local tfuelLBS_L    = Text.new("3500",    TXT_12B_R, {"#00FF00","#FFFF00","#FF0000"},    137, 577, 40, 12, tCONST)
local tfuelLBS_R    = Text.new("3500",    TXT_12B_R, {"#00FF00","#FFFF00","#FF0000"},    465, 577, 40, 12, tCONST)
local tfuelLBS_USED = Text.new("0",       TXT_12B_R, {"#00FF00"},    503, 463, 40, 12, tCONST)
local tfuelTEMP     = Text.new("38",      TXT_12B_R, {"#00FF00"},    451, 548, 40, 12, tCONST)

local ifuelPORT1_L  = Image.new("fuelp_rfport.png",      244, 536,  15, 54, tOPTIONAL)
local ifuelPORT2_L  = Image.new("fuelp_rfport2_l.png",   184, 515,  55, 15, tOPTIONAL)

local ifuelPORT1_R  = Image.new("fuelp_rfport.png",      415, 536,  15, 54, tOPTIONAL)
local ifuelPORT2_R  = Image.new("fuelp_rfport2_r.png",   435, 515,  55, 15, tOPTIONAL)

local ifuelEL_PP_L  = Image.new("fuelp_pump.png",        274, 550,  24, 23, tOPTIONAL)
local ifuelEL_L1_L  = Image.new("green_line.png",        284, 535,   4, 14, tGROUPED)
local ifuelEL_L2_L  = Image.new("green_line.png",        284, 574,   4, 19, tGROUPED)
local ifuelEL_L3_L  = Image.new("green_line.png",        251, 589,  37,  4, tGROUPED)
local gfuelEL_L     = Group.new({ifuelEL_L1_L,ifuelEL_L2_L,ifuelEL_L3_L}, tOPTIONAL)

local ifuelEL_PP_R  = Image.new("fuelp_pump.png",        376, 550,  24, 23, tOPTIONAL)
local ifuelEL_L1_R  = Image.new("green_line.png",        386, 535,   4, 14, tGROUPED)
local ifuelEL_L2_R  = Image.new("green_line.png",        386, 574,   4, 19, tGROUPED)
local ifuelEL_L3_R  = Image.new("green_line.png",        386, 589,  37,  4, tGROUPED)
local gfuelEL_R     = Group.new({ifuelEL_L1_R,ifuelEL_L2_R,ifuelEL_L3_R}, tOPTIONAL)

local ifuelGRAV_L1  = Image.new("green_line.png",        265, 478, 145,  4, tGROUPED)
local ifuelGRAV_VV  = Image.new("antice_page3.png",      324, 469,  25, 25, tGROUPED)
local gfuelGRAV     = Group.new({ifuelGRAV_L1,ifuelGRAV_VV}, tOPTIONAL)

local ifuelXFED_L1  = Image.new("green_line.png",        296, 559,  82,  4, tOPTIONAL)
local ifuelXFED_VV  = Image.new("antice_page3.png",      324, 549,  25, 25, tOPTIONAL)

local ifuelENG_L1_L = Image.new("green_line.png",        250, 590,   3, 97, tGROUPED)
local ifuelENG_VV_L = Image.new("antice_page6.png",      240, 641,  24, 24, tGROUPED)
local ifuelENG_EN_L = Image.new("fuelp_engn_l.png",      171, 713,  82, 22, tGROUPED)
local gfuelENG_L    = Group.new({ifuelENG_L1_L,ifuelENG_VV_L,ifuelENG_EN_L}, tOPTIONAL)

local ifuelENG_L1_R = Image.new("green_line.png",        420, 590,   4, 99, tGROUPED)
local ifuelENG_VV_R = Image.new("antice_page6.png",      410, 641,  24, 24, tGROUPED)
local ifuelENG_EN_R = Image.new("fuelp_engn_r.png",      419, 713,  83, 22, tGROUPED)
local gfuelENG_R    = Group.new({ifuelENG_L1_R,ifuelENG_VV_R,ifuelENG_EN_R}, tOPTIONAL)

local ifuelAPU_L1   = Image.new("green_line.png",        335, 627,  86,  4, tGROUPED)
local ifuelAPU_L2   = Image.new("green_line.png",        420, 581,   4, 50, tGROUPED)
local ifuelAPU_L3   = Image.new("green_line.png",        335, 631,   4, 95, tGROUPED)
local ifuelAPU_VV   = Image.new("antice_page6.png",      325, 660,  24, 24, tGROUPED)
local gfuelAPU      = Group.new({ifuelAPU_L1,ifuelAPU_L2,ifuelAPU_L3,ifuelAPU_VV}, tOPTIONAL)

xpl_dataref_subscribe("sim/flightmodel/weight/m_fuel1",                 "FLOAT", 
                      "sim/flightmodel/weight/m_fuel2",                 "FLOAT", 
                      "cl300/fuel_imbalanced",                          "INT",
    function(vl, vr, i)
        local l = vl*2.20462262
        local r = vr*2.20462262
        local s = l+r
        local c = (s < 1400 and 3 or (i > 0 and 2 or 1))
        tfuelLBS_L:text(limit(l,0))
        tfuelLBS_R:text(limit(r,0))
        tfuelLBS_SUM:text(limit(s,0))
        tfuelLBS_L:colorindex(c)
        tfuelLBS_R:colorindex(c)
        tfuelLBS_SUM:colorindex(c)
    end)

xpl_dataref_subscribe("cl300/fuel_used",                                "FLOAT", function(v) tfuelLBS_USED:text(limit(v*2.20462262,0)) end)
xpl_dataref_subscribe("sim/weather/temperature_ambient_c",              "FLOAT", function(v) tfuelTEMP:text(limit(math.atan(v/106)*19+15,0)) end)

xpl_dataref_subscribe("sim/flightmodel/engine/ENGN_running",            "INT[8]",
                      "sim/cockpit2/electrical/APU_running",            "INT",
                      "sim/cockpit2/engine/actuators/fuel_pump_on",     "INT[8]",
                      "cl300/fuel_xflow_dn_h",                          "INT",
                      "cl300/en_but_run_l",                             "INT",
                      "cl300/en_but_run_r",                             "INT",
                      "sim/cockpit/engine/APU_switch",                  "INT",
    function(eng, apu, pmp, xf, so_l, so_r, so_a)
        local hasxf = (xf == 1 and pmp[1]+pmp[2] == 1)
        ifuelPORT1_L:showElem( eng[1] == 1)
        ifuelPORT2_L:showElem((eng[1] == 1 or pmp[1] == 1 or hasxf))
        ifuelPORT1_R:showElem((eng[2] == 1 or apu == 1))
        ifuelPORT2_R:showElem((eng[2] == 1 or apu == 1 or pmp[2] == 1) or hasxf)
        
        ifuelXFED_VV:showElem(xf > 0)
        ifuelXFED_L1:showElem(xf > 0 and (pmp[1]+pmp[2] == 1)) -- only one pump running
        
        ifuelEL_PP_L:showElem(pmp[1] == 1)
        ifuelEL_PP_R:showElem(pmp[2] == 1)
        
        gfuelEL_L:showElem(pmp[1] == 1 or hasxf)
        gfuelEL_R:showElem(pmp[2] == 1 or hasxf)
        
        gfuelENG_L:showElem(so_l == 1 and (eng[1] == 1 or pmp[1] == 1 or hasxf))
        gfuelENG_R:showElem(so_r == 1 and (eng[2] == 1 or pmp[2] == 1 or hasxf))
        gfuelAPU:showElem(  so_a  > 0 and (apu    == 1 or pmp[2] == 1 or hasxf))
    end)

xpl_dataref_subscribe("cl300/fuel_xflow_up_h", "INT", function(v) gfuelGRAV:showElem(v > 0) end)



PAGE:finalize()

