PAGE = Page.new("cl300/mfd_antice_" .. SIDE, "ICE.png", 0, 412, 670, 392)

-- L side
local iiceINTK_L     = Image.new("antice_page1.png",         35, 666,  89,  27, tOPTIONAL)  -- get(ice_inlet_heat_on) > 0 and get(antice_engn_l_h) > 0 and get(ENGN_running_l) > 0
local iiceENG_L1_L   = Image.new("green_line.png",           79, 711,  68,   4, tGROUPED )  -- get(ENGN_running_l) > 0
local iiceENG_L2_L   = Image.new("green_line.png",          136, 678,   4,  35, tGROUPED )  -- get(ENGN_running_l) > 0
local iiceENG_L3_L   = Image.new("green_line.png",          124, 678,  15,   4, tGROUPED )  -- get(ENGN_running_l) > 0
local giceENG_L      = Group.new({iiceENG_L1_L, iiceENG_L2_L, iiceENG_L3_L},    tOPTIONAL)
local iiceBLEED_L1_L = Image.new("green_line.png",          171, 711,  27,   4, tGROUPED )  -- get(antice_wngsource_r) < 2 and get(ENGN_running_l) > 0
local iiceBLEED_L2_L = Image.new("green_line.png",          228, 711,  29,   4, tGROUPED )  -- get(antice_wngsource_r) < 2 and get(ENGN_running_l) > 0 
local iiceBLEED_VV_L = Image.new("antice_page3.png",        147, 702,  23,  23, tGROUPED )  -- get(antice_wngsource_r) < 2 and get(ENGN_running_l) > 0
local giceBLEED_L    = Group.new({iiceBLEED_L1_L,iiceBLEED_L2_L,iiceBLEED_VV_L}, tOPTIONAL)
local iiceWING_VV_L  = Image.new("antice_page3.png",        258, 702,  23,  23, tOPTIONAL)  -- get(antice_wngsource_r) < 2 and get(ENGN_running_l) > 0 and get(antice_wing_h) > 0
local iiceWING_L1_L  = Image.new("green_line.png",          294, 475,   4, 240, tGROUPED )  -- get(ice_surfce_heat_left_on) > 0
local iiceWING_L2_L  = Image.new("green_line.png",          283, 711,  16,   4, tGROUPED )  -- get(ice_surfce_heat_left_on) > 0
local iiceWING_L     = Image.new("antice_page4.png",         81, 470, 213, 113, tGROUPED )  -- get(ice_surfce_heat_left_on) > 0
local giceWING_L     = Group.new({iiceWING_L1_L, iiceWING_L2_L, iiceWING_L},    tOPTIONAL)
-- R side
local iiceINTK_R     = Image.new("antice_page2.png",        550, 666,  89,  27, tOPTIONAL)  -- get(ice_inlet_heat_on) > 0 and get(antice_engn_r_h) > 0 and get(ENGN_running_r) > 0
local iiceENG_L1_R   = Image.new("green_line.png",          527, 711,  68,   4, tGROUPED )  -- get(ENGN_running_r) > 0
local iiceENG_L2_R   = Image.new("green_line.png",          534, 678,   4,  35, tGROUPED )  -- get(ENGN_running_r) > 0
local iiceENG_L3_R   = Image.new("green_line.png",          534, 678,  15,   4, tGROUPED )  -- get(ENGN_running_r) > 0
local giceENG_R      = Group.new({iiceENG_L1_R, iiceENG_L2_R, iiceENG_L3_R},    tOPTIONAL)
local iiceBLEED_L1_R = Image.new("green_line.png",          416, 711,  30,   4, tGROUPED )  -- get(antice_wngsource_r) > 0 and get(ENGN_running_r) > 0
local iiceBLEED_L2_R = Image.new("green_line.png",          476, 711,  27,   4, tGROUPED )  -- get(antice_wngsource_r) > 0 and get(ENGN_running_r) > 0
local iiceBLEED_VV_R = Image.new("antice_page3.png",        503, 702,  23,  23, tGROUPED )  -- get(antice_wngsource_r) > 0 and get(ENGN_running_r) > 0
local giceBLEED_R    = Group.new({iiceBLEED_L1_R,iiceBLEED_L2_R,iiceBLEED_VV_R}, tOPTIONAL)
local iiceWING_VV_R  = Image.new("antice_page3.png",        392, 702,  23,  23, tOPTIONAL)  -- get(antice_wngsource_r) > 0 and get(ENGN_running_r) > 0 and get(antice_wing_h) > 0
local iiceWING_L1_R  = Image.new("green_line.png",          376, 475,   4, 240, tGROUPED )  -- get(ice_surfce_heat_right_on) > 0
local iiceWING_L2_R  = Image.new("green_line.png",          376, 711,  16,   4, tGROUPED )  -- get(ice_surfce_heat_right_on) > 0
local iiceWING_R     = Image.new("antice_page5.png",        380, 470, 212, 113, tGROUPED )  -- get(ice_surfce_heat_right_on) > 0
local giceWING_R     = Group.new({iiceWING_L1_R, iiceWING_L2_R, iiceWING_R},    tOPTIONAL)
-- X bleed
local iiceBLEED_L1_X = Image.new("green_line.png",          283, 711, 108,   4, tGROUPED )  -- get(antice_wing_h) > 0 and ((get(ENGN_running_l) > 0 and get(antice_wngsource_r) == 0) or (get(ENGN_running_r) > 0 and get(antice_wngsource_r) == 2))
local iiceBLEED_VV_X = Image.new("antice_page3.png",        325, 702,  23,  23, tGROUPED )  -- get(antice_wing_h) > 0 and ((get(ENGN_running_l) > 0 and get(antice_wngsource_r) == 0) or (get(ENGN_running_r) > 0 and get(antice_wngsource_r) == 2))
local giceBLEED_X    = Group.new({iiceBLEED_L1_X, iiceBLEED_VV_X},                tOPTIONAL)

local iicePSI_L      = Text.new("30", TXT_12B_R, {"#CCCCCC"}, 202, 699, 20, 12, tCONST)
local iicePSI_R      = Text.new("30", TXT_12B_R, {"#CCCCCC"}, 450, 699, 20, 12, tCONST)

xpl_dataref_subscribe("sim/flightmodel/engine/ENGN_running",        "INT[8]",
                      "sim/cockpit2/ice/ice_inlet_heat_on",         "INT",
                      "cl300/antice_wing_h",                        "INT",
                      "cl300/antice_engn_l_h",                      "INT",
                      "cl300/antice_engn_r_h",                      "INT",
                      "cl300/antice_wngsource_r",                   "INT",
	function(eng, inlet, wing, eng_l, eng_r, src)
        iiceINTK_L:showElem(eng[1] > 0 and inlet > 0 and eng_l > 0)
        iiceINTK_R:showElem(eng[2] > 0 and inlet > 0 and eng_r > 0)
        giceENG_L:showElem(eng[1] > 0)
        giceENG_R:showElem(eng[2] > 0 )
        giceBLEED_L:showElem(eng[1] > 0 and src < 2)
        giceBLEED_R:showElem(eng[2] > 0 and src > 0)
        iiceWING_VV_L:showElem(eng[1] > 0 and src < 2 and wing > 0)
        iiceWING_VV_R:showElem(eng[2] > 0 and src > 0 and wing > 0)
        end)
xpl_dataref_subscribe("sim/cockpit2/ice/ice_surfce_heat_left_on",  "INT", function(sh) giceWING_L:showElem(sh > 0) end)
xpl_dataref_subscribe("sim/cockpit2/ice/ice_surfce_heat_right_on", "INT", function(sh) giceWING_R:showElem(sh > 0) end)
xpl_dataref_subscribe("cl300/antice_wings_xbleed_valve",           "INT", function(xv) giceBLEED_X:showElem(xv > 0) end)
xpl_dataref_subscribe("cl300/antice_psi_l", "FLOAT", function(psi) iicePSI_L:text(limit(psi,0)) end)
xpl_dataref_subscribe("cl300/antice_psi_r", "FLOAT", function(psi) iicePSI_R:text(limit(psi,0)) end)

PAGE:finalize()
