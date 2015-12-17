PAGE = Page.new("cl300/mfd_hydr_" .. SIDE, "HYDR.png", 0, 412, 670, 392)

-- left hs
-- engn sov and pump
local ihydrENG_L1_L = Image.new("green_line.png",         73, 581,   4,  41, tGROUPED)
local ihydrENG_L2_L = Image.new("green_line.png",        129, 492,   4,  93, tGROUPED)
local ihydrENG_L3_L = Image.new("green_line.png",         73, 618,  75,   4, tGROUPED)
local ihydrENG_L4_L = Image.new("green_line.png",         73, 581,  60,   4, tGROUPED)
local ihydrENG_PP_L = Image.new("fuelp_pump.png",         63, 591,  24,  23, tGROUPED)
local ghdyrENG_L    = Group.new({ihydrENG_L1_L,ihydrENG_L2_L,ihydrENG_L3_L,ihydrENG_L4_L,ihydrENG_PP_L}, tOPTIONAL)
local ihydrSOV_L    = Image.new("antice_page6.png",      120, 516,  23,  23, tOPTIONAL)
-- left dc pump
local ihydrELC_L1_L = Image.new("green_line.png",        218, 492,   4, 130, tGROUPED)
local ihydrELC_L2_L = Image.new("green_line.png",        184, 618,  36,   4, tGROUPED)
local ihydrELC_PP_L = Image.new("fuelp_pump.png",        208, 538,  24,  23, tGROUPED)
local ghdyrELC_L    = Group.new({ihydrELC_L1_L,ihydrELC_L2_L,ihydrELC_PP_L}, tOPTIONAL)
-- PTU valve
local ihydrPTU_L1   = Image.new("green_line.png",        252, 539,   4, 209, tGROUPED)
local ihydrPTU_VV   = Image.new("antice_page6.png",      243, 537,  23,  23, tGROUPED)
local ghdyrPTU      = Group.new({ihydrPTU_L1,ihydrPTU_VV}, tOPTIONAL)
-- ptu gear
local ihydrPTU_HD   = Image.new("hd_gear.png",           235, 757,  35,  11, tOPTIONAL)
-- actual hydr left
local ihydrSYS_L1_L = Image.new("green_line.png",         49, 662, 119,   4, tGROUPED)
local ihydrSYS_L2_L = Image.new("green_line.png",         49, 665,   4,  14, tGROUPED)
local ihydrSYS_L3_L = Image.new("green_line.png",        164, 638,   4,  40, tGROUPED)
local ihydrSYS_HD_L = Image.new("hd_l_hs.png",           102, 687, 124, 108, tGROUPED)
local ihydrSYS_PR_L = Image.new("hd_press_norm.png",       8, 684,  40,  23, tGROUPED)
local ihydrSYS_BR_L = Image.new("hd_inb_brk.png",          3, 720,  97,  21, tGROUPED)
local ghdyrSYS_L    = Group.new({ihydrSYS_L1_L,ihydrSYS_L2_L,ihydrSYS_L3_L,ihydrSYS_HD_L,ihydrSYS_PR_L,ihydrSYS_BR_L}, tOPTIONAL)
-- right hs
-- right engn sov and pump
local ihydrENG_L1_R = Image.new("green_line.png",        596, 581,   4,  41, tGROUPED)
local ihydrENG_L2_R = Image.new("green_line.png",        539, 492,   4,  93, tGROUPED)
local ihydrENG_L3_R = Image.new("green_line.png",        518, 618,  78,   4, tGROUPED)
local ihydrENG_L4_R = Image.new("green_line.png",        539, 581,  60,   4, tGROUPED)
local ihydrENG_PP_R = Image.new("fuelp_pump.png",        586, 591,  24,  23, tGROUPED)
local ghdyrENG_R    = Group.new({ihydrENG_L1_R,ihydrENG_L2_R,ihydrENG_L3_R,ihydrENG_L4_R,ihydrENG_PP_R}, tOPTIONAL)
local ihydrSOV_R    = Image.new("antice_page6.png",      530, 516,  23,  23, tOPTIONAL)
-- right dc pump
local ihydrELC_L1_R = Image.new("green_line.png",        451, 492,   4, 130, tGROUPED)
local ihydrELC_L2_R = Image.new("green_line.png",        451, 618,  29,   4, tGROUPED)
local ihydrELC_PP_R = Image.new("fuelp_pump.png",        440, 538,  24,  23, tGROUPED)
local ghdyrELC_R    = Group.new({ihydrELC_L1_R,ihydrELC_L2_R,ihydrELC_PP_R}, tOPTIONAL)
-- actual hydr right
local ihydrSYS_L1_R = Image.new("green_line.png",        497, 662, 118,   4, tGROUPED)
local ihydrSYS_L2_R = Image.new("green_line.png",        611, 665,   4,  14, tGROUPED)
local ihydrSYS_L3_R = Image.new("green_line.png",        497, 638,   4,  40, tGROUPED)
local ihydrSYS_HD_R = Image.new("hd_r_hs.png",           434, 687, 123, 108, tGROUPED)
local ihydrSYS_PR_R = Image.new("hd_press_norm.png",     592, 684,  40,  23, tGROUPED)
local ihydrSYS_BR_R = Image.new("hd_outb_brk.png",       585, 718,  51,  23, tGROUPED)
local ghdyrSYS_R    = Group.new({ihydrSYS_L1_R,ihydrSYS_L2_R,ihydrSYS_L3_R,ihydrSYS_HD_R,ihydrSYS_PR_R,ihydrSYS_BR_R}, tOPTIONAL)
-- AUX hs
local ihydrAUX_L1   = Image.new("green_line.png",        337, 619,   4,  59, tGROUPED)
local ihydrAUX_L2   = Image.new("green_line.png",        337, 512,   4,  74, tGROUPED)
local ihydrAUX_PP   = Image.new("fuelp_pump.png",        327, 538,  24,  23, tGROUPED)
local ihydrAUX_HD   = Image.new("hd_rudd.png",           312, 686,  52,  10, tGROUPED)
local ghdyrAUX      = Group.new({ihydrAUX_L1,ihydrAUX_L2,ihydrAUX_PP,ihydrAUX_HD}, tOPTIONAL)
-- TEXT
local thydrPRESS_L  = Text.new("2981", TXT_12B_C, {"#00FF00"}, 148, 608, 36, 12, tCONST)
local thydrPRESS_R  = Text.new("2981", TXT_12B_C, {"#00FF00"}, 481, 608, 36, 12, tCONST)
local thydrPRESS_A  = Text.new("2981", TXT_12B_C, {"#00FF00"}, 322, 589, 36, 12, tCONST)
local thydrQTY_L    = Text.new("85",   TXT_12B_R, {"#00FF00"}, 146, 473, 36, 12, tCONST)
local thydrQTY_R    = Text.new("85",   TXT_12B_R, {"#00FF00"}, 469, 473, 36, 12, tCONST)
local thydrQTY_A    = Text.new("85",   TXT_12B_R, {"#00FF00"}, 308, 493, 36, 12, tCONST)
local thydrTEMP_L   = Text.new("100",  TXT_12B_R, {"#00FF00"}, 145, 431, 36, 12, tCONST)
local thydrTEMP_R   = Text.new("100",  TXT_12B_R, {"#00FF00"}, 468, 431, 36, 12, tCONST)
local thydrTEMP_A   = Text.new("100",  TXT_12B_R, {"#00FF00"}, 307, 460, 36, 12, tCONST)
local thydrBRK_PSI  = Text.new("2900", TXT_14B_R, {"#00FF00","#CCCC00"}, 53, 686, 40, 14, tCONST) --728

xpl_dataref_subscribe("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1", "FLOAT",
                      "cl300/hd_l_engn_state", "INT", 
                      "cl300/hd_l_pump_state", "INT",  
    function(v,e,p) 
        if e+p == 0 then thydrPRESS_L:text(0) 
        else             thydrPRESS_L:text(limit(v,0)) end
    end)
xpl_dataref_subscribe("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_2", "FLOAT", 
                      "cl300/hd_r_engn_state", "INT", 
                      "cl300/hd_r_pump_state", "INT",  
    function(v,e,p) 
        if e+p == 0 then thydrPRESS_R:text(0) 
        else             thydrPRESS_R:text(limit(v,0)) end
    end)
xpl_dataref_subscribe("cl300/hd_aux_state", "INT", function(v) thydrPRESS_A:text(v > 0 and 2981 or 0) end)
xpl_dataref_subscribe("sim/weather/temperature_ambient_c", "FLOAT", function(v) 
	local ht = math.atan(v/106)*19 + 25
	thydrTEMP_L:text(limit(ht-0.3,0))
	thydrTEMP_R:text(limit(ht+0.3,0))
	thydrTEMP_A:text(limit(ht+1.1,0))
end)
xpl_dataref_subscribe("sim/cockpit2/hydraulics/indicators/hydraulic_fluid_ratio_1", "FLOAT", 
                      "sim/flightmodel2/gear/deploy_ratio",                         "FLOAT[10]", 
    function(v,g) 
        thydrQTY_L:text(limit(v * (100 - 11.7 * (g[1]+g[2]+g[3])),0)) 
    end)
xpl_dataref_subscribe("sim/cockpit2/hydraulics/indicators/hydraulic_fluid_ratio_2", "FLOAT", function(v) thydrQTY_R:text(limit(v * 100,0)) end)

xpl_dataref_subscribe("cl300/hd_l_engn_state", "INT", 
                      "cl300/hd_l_pump_state", "INT", 
    function(e,p) 
        ghdyrENG_L:showElem(e == 1) 
        ghdyrELC_L:showElem(p == 1) 
        ghdyrSYS_L:showElem(e+p > 0) 
		thydrBRK_PSI:text((e+p> 0) and "2870" or "1200") 
		thydrBRK_PSI:colorindex((e+p > 0) and 1 or 2)
    end)
xpl_dataref_subscribe("cl300/hd_r_engn_state", "INT", 
                      "cl300/hd_r_pump_state", "INT", 
    function(e,p) 
        ghdyrENG_R:showElem(e == 1) 
        ghdyrELC_R:showElem(p == 1) 
        ghdyrSYS_R:showElem(e == 1 or p == 1) 
    end)
xpl_dataref_subscribe("cl300/hd_aux_state", "INT", function(v) ghdyrAUX:showElem(v == 1) end)
xpl_dataref_subscribe("cl300/hydr_l_sov_h", "INT", function(v) ihydrSOV_L:showElem(v == 1) end)
xpl_dataref_subscribe("cl300/hydr_r_sov_h", "INT", function(v) ihydrSOV_R:showElem(v == 1) end)

xpl_dataref_subscribe("cl300/hd_l_engn_state", "INT", 
                      "cl300/hd_l_pump_state", "INT", 
                      "cl300/hd_ptu_state",    "INT", 
                      "cl300/ptu_h",           "INT", 
    function(eng,elec,ptu,h) 
        ghdyrPTU:showElem(h > 0 and ptu == 1 and (h == 2 or eng+elec == 0))
        ihydrPTU_HD:showElem(ptu == 1) 
    end)
-- ******************
--[[
xpl_dataref_subscribe("cl300/hd_l_pump_state", "INT", "cl300/hd_l_engn_state", "INT", 
	function(v,w) 
	end)
    --]]

PAGE:finalize()
