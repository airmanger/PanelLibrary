if CAPTAIN then
	local ttopTHR_L    = Text.new("98.0 APR",   TXT_14B_L, {"#00FFFF"},                      53,   5,  85,  14, tCONST)
	local ttopTHR_R    = Text.new("98.0 APR",   TXT_14B_L, {"#00FFFF"},                     183,   5,  85,  14, tCONST)
	local ttopN1_L     = Text.new("99.9",       TXT_18B_L, {"#00FF00", "#FF0000"},           58,  24,  65,  18, tCONST)
	local ttopN1_R     = Text.new("99.9",       TXT_18B_L, {"#00FF00", "#FF0000"},          188,  24,  65,  18, tCONST)
	local itopN1_L     = Image.new("n1_needle.png",                                          53,   2,   5,  88, tCONST)
	local itopN1_R     = Image.new("n1_needle.png",                                         183,   2,   5,  88, tCONST)
	local itopN1_LC3   = Image.new("blue_arrow_line3.png",                                   51, -10,   9, 110, tOPTIONAL)
	local itopN1_RC3   = Image.new("blue_arrow_line3.png",                                  181, -10,   9, 110, tOPTIONAL)
	local itopN1_LC2   = Image.new("blue_arrow_line2.png",                                   51, -10,   9, 110, tOPTIONAL)
	local itopN1_RC2   = Image.new("blue_arrow_line2.png",                                  181, -10,   9, 110, tOPTIONAL)
	local ttopREV_L    = Text.new("REV",        TXT_14B_L, {"#CCCCCC", "#00FF00"},           40, 103,  85,  14, tOPTIONAL)
	local ttopREV_R    = Text.new("REV",        TXT_14B_L, {"#CCCCCC", "#00FF00"},          170, 103,  85,  14, tOPTIONAL)
	local ttopIGN_L    = Text.new("IGN",        TXT_14B_L, {"#FFFF00"},                      70, 210,  56,  14, tOPTIONAL) 
	local ttopIGN_R    = Text.new("IGN",        TXT_14B_L, {"#FFFF00"},                     140, 210,  56,  14, tOPTIONAL) 
	local ttopFIRE_L   = Text.new("FIRE",       TXT_20B_L, {"#FF0000"},                      31,  54,  65,  20, tOPTIONAL) 
	local ttopFIRE_R   = Text.new("FIRE",       TXT_20B_L, {"#FF0000"},                     161,  54,  65,  20, tOPTIONAL) 
	local ttopMACH     = Text.new("MACH\nHOLD", TXT_12B_C, {"#00FF00", "#AAAAAA"},           92,  79,  55,  35, tOPTIONAL) 
	local ttopSYNC     = Text.new("SYNC", 	    TXT_12B_C, {"#00FF00", "#FFFF00"},           92,  86,  55,  14, tOPTIONAL) 
	local ttopITT_L    = Text.new("999",        TXT_18B_L, {"#00FF00", "#FF0000"},           62, 142,  65,  18, tCONST)
	local ttopITT_R    = Text.new("999",        TXT_18B_L, {"#00FF00", "#FF0000"},          192, 142,  65,  18, tCONST)
	local itopITT_L    = Image.new("n1_needle.png",                                          53, 121,   5,  88, tCONST)
	local itopITT_R    = Image.new("n1_needle.png",                                         183, 121,   5,  88, tCONST)
	local itopSTART_L  = Image.new("start.png",                                              16, 230,  14,  75, tOPTIONAL)
	local itopSTART_R  = Image.new("start.png",                                             212, 230,  14,  75, tOPTIONAL)
	local ttopN2_L     = Text.new("69.9",       TXT_14B_R, {"#00FF00", "#FF0000"},           25, 233,  55,  14, tCONST)
	local ttopN2_R     = Text.new("69.9",       TXT_14B_R, {"#00FF00", "#FF0000"},          145, 233,  55,  14, tCONST) 
	local ttopOP_L     = Text.new("105",        TXT_14B_R, {"#00FF00", "#FF0000"},           25, 250,  55,  14, tCONST)
	local ttopOP_R     = Text.new("105",        TXT_14B_R, {"#00FF00", "#FF0000"},          145, 250,  55,  14, tCONST) 
	local ttopOT_L     = Text.new("135",        TXT_14B_R, {"#00FF00", "#FF0000"},           25, 267,  55,  14, tCONST)
	local ttopOT_R     = Text.new("135",        TXT_14B_R, {"#00FF00", "#FF0000"},          145, 267,  55,  14, tCONST) 
	local ttopFF_L     = Text.new("1500",       TXT_14B_R, {"#00FF00"},                      25, 284,  55,  14, tCONST)
	local ttopFF_R     = Text.new("1500",       TXT_14B_R, {"#00FF00"},                     145, 284,  55,  14, tCONST) 
	local ttopFUEL_SUM = Text.new("4500",       TXT_14B_R, {"#00FF00","#FFFF00","#FF0000"}, 120, 374,  55,  14, tCONST) 
	local ttopFUEL_L   = Text.new("2250",       TXT_14B_R, {"#00FF00","#FFFF00","#FF0000"},  40, 391,  55,  14, tCONST) 
	local ttopFUEL_R   = Text.new("2250",       TXT_14B_R, {"#00FF00","#FFFF00","#FF0000"}, 135, 391,  55,  14, tCONST) 
	local ttopAPU_RPM  = Text.new("100",        TXT_14B_R, {"#00FF00"},                     120, 314,  55,  14, tGROUPED)
	local ttopAPU_EGT  = Text.new("750",        TXT_14B_R, {"#00FF00"},                     120, 331,  55,  14, tGROUPED) 
	local itopAPU      = Image.new("black.png",                                               0, 313, 180,  35, tOPTIONAL)
	local gtopAPU      = Group.new({ttopAPU_RPM, ttopAPU_EGT},                                                  tOPTIONAL)
	
	gtopAPU:showElem(false)
	local APU_RUNNING = 0
	function apu_timer() if APU_RUNNING == 0 then gtopAPU:showElem(false) end end
	-- show/hide APU INFO
	xpl_dataref_subscribe("sim/cockpit2/electrical/APU_running", "INT", 
		function(v) APU_RUNNING = v if v == 0 then timer_start(15000,nil,apu_timer) else gtopAPU:showElem(true)  itopAPU:showElem(false)  end end)
	-- ING
	xpl_dataref_subscribe("sim/cockpit2/engine/actuators/igniter_on", "INT[8]", 
		function(v) 
			ttopIGN_L:showElem(v[1] == 1) 
			ttopIGN_R:showElem(v[2] == 1) 
		end)
	-- FIRE
	xpl_dataref_subscribe("sim/cockpit/warnings/annunciators/engine_fires", "INT[8]", 
		function(v) 
			ttopFIRE_L:showElem(v[1] == 1) 
			ttopFIRE_R:showElem(v[2] == 1) 
		end)
		
	local TO_n1 = 0
	local engine_state_l = 0 
	local engine_state_r = 0
	-- N1 LIMITS
	xpl_dataref_subscribe("cl300/TO_n1", "FLOAT", "cl300/engine_state_l", "INT", "cl300/engine_state_r", "INT", 
		function(n1, e1, e2)
			local n1_ = limit(n1,1)
			if n1_ ~= TO_n1 or e1 ~= engine_state_l then
				if     e1 == 4  then ttopTHR_L:text(n1_ .. " APR")
				elseif e1 == 3  then ttopTHR_L:text(n1_ .. " TO")
				elseif e1 == 2  then ttopTHR_L:text(n1_ .. " CLB")
				elseif e1 == 1  then ttopTHR_L:text(n1_ .. " CRZ")
				elseif e1 == -1 then ttopTHR_L:text("70.7 REV")
				else                 ttopTHR_L:text("") end
				if e1 ~= engine_state_l then
					itopN1_LC2:showElem(e1 > 1)
					itopN1_LC3:showElem(e1 == 1)
				end
				if e1 == 1 then
					itopN1_LC3:rotate(n1 * 2.4 + 90) -- WAS 95, TODO VERIFY
				elseif e1 > 1 then
					itopN1_LC2:rotate(n1 * 2.4 + 90)
				end
				engine_state_l = e1
			end
			
			if n1_ ~= TO_n1 or e2 ~= engine_state_r then
				if     e2 == 4  then ttopTHR_R:text(n1_ .. " APR")
				elseif e2 == 3  then ttopTHR_R:text(n1_ .. " TO")
				elseif e2 == 2  then ttopTHR_R:text(n1_ .. " CLB")
				elseif e2 == 1  then ttopTHR_R:text(n1_ .. " CRZ")
				elseif e2 == -1 then ttopTHR_R:text("70.7 REV")
				else                 ttopTHR_R:text("") end
				if e2 ~= engine_state_r then
					itopN1_RC2:showElem(e2 > 1)
					itopN1_RC3:showElem(e2 == 1)
				end
				if e2 == 1 then
					itopN1_RC3:rotate(n1 * 2.4 + 90) -- WAS 95, TODO VERIFY
				elseif e2 > 1 then
					itopN1_RC2:rotate(n1 * 2.4 + 90)
				end
				engine_state_r = e2
			end
			TO_n1 = n1_
		end)
	-- N1
	xpl_dataref_subscribe("sim/flightmodel/engine/ENGN_N1_", "FLOAT[8]", 
		function(v)  
			ttopN1_L:text(limit(v[1],1))
			ttopN1_R:text(limit(v[2],1))
			ttopN1_L:colorindex(v[1] < 96.1 and 1 or 2)
			ttopN1_R:colorindex(v[2] < 96.1 and 1 or 2)
			ttopSYNC:colorindex(math.abs(v[1] - v[2]) < 0.1 and 1 or 2)
			itopN1_L:rotate(v[1]* 2.4 + 90)
			itopN1_R:rotate(v[2]* 2.4 + 90)
		end)
	-- REV
	xpl_dataref_subscribe("sim/flightmodel2/engines/thrust_reverser_deploy_ratio", "FLOAT[8]", 
		function (v) 
			ttopREV_L:showElem(v[1] > .1)
			ttopREV_R:showElem(v[2] > .1)
			ttopREV_L:colorindex(v[1] < .9 and 1 or 2)
			ttopREV_R:colorindex(v[2] < .9 and 1 or 2)
		end)
	-- ITT
	xpl_dataref_subscribe("sim/flightmodel/engine/ENGN_ITT_c", "FLOAT[8]", 
		function(v)  
			ttopITT_L:text(limit(v[1],0))
			ttopITT_R:text(limit(v[2],0))
			ttopITT_L:colorindex(v[1] < 948 and 1 or 2)
			ttopITT_R:colorindex(v[2] < 948 and 1 or 2)
			itopITT_L:rotate(math.min(v[1]/4.2 + 90, 320))
			itopITT_R:rotate(math.min(v[2]/4.2 + 90, 320))
		end)
	-- START
	xpl_dataref_subscribe("cl300/s_l", "INT", function(v) itopSTART_L:showElem(v ~= 0) end)
	xpl_dataref_subscribe("cl300/s_r", "INT", function(v) itopSTART_R:showElem(v ~= 0) end)
	-- N2
	xpl_dataref_subscribe("sim/flightmodel/engine/ENGN_N2_", "FLOAT[8]", 
		function(v)  
			ttopN2_L:text(limit(v[1],1))
			ttopN2_R:text(limit(v[2],1))
			ttopN2_L:colorindex(v[1] < 98.1 and 1 or 2)
			ttopN2_R:colorindex(v[2] < 98.1 and 1 or 2)
		end)
	-- OIL PRESS
	xpl_dataref_subscribe("sim/flightmodel/engine/ENGN_oil_press_psi", "FLOAT[8]", 
		function(v)  
			ttopOP_L:text(limit(v[1],0))
			ttopOP_R:text(limit(v[2],0))
			ttopOP_L:colorindex((v[1] < 138 and v[1] > 27) and 1 or 2)
			ttopOP_R:colorindex((v[2] < 138 and v[2] > 27) and 1 or 2)
		end)
	-- OIL TEMP
	xpl_dataref_subscribe("cl300/oil_temp_left_smooth",  "FLOAT", 
		function(vl)  
			ttopOT_L:text(limit(vl,0))
			ttopOT_L:colorindex((vl < 138 and vl > 27) and 1 or 2)
		end)
	xpl_dataref_subscribe("cl300/oil_temp_right_smooth", "FLOAT",  
		function(vr)  
			ttopOT_R:text(limit(vr,0))
			ttopOT_R:colorindex((vr < 138 and vr > 27) and 1 or 2)
		end)
	-- FUEL FLOW
	xpl_dataref_subscribe("sim/flightmodel/engine/ENGN_FF_", "FLOAT[8]", 
		function(v)  
			ttopFF_L:text(limit(v[1]*7936.64,0))
			ttopFF_R:text(limit(v[2]*7936.64,0))
		end)
	-- APU N1/EGT
	xpl_dataref_subscribe("sim/cockpit2/electrical/APU_N1_percent", "FLOAT", 
                          "sim/weather/temperature_ambient_c",      "FLOAT", 
		function(v,w)  
			ttopAPU_RPM:text(limit(v,0))
			local egt
			if v < 40 then
				egt = w + v * 24
			else
				egt = w + 960 - v * 2.9
			end
			ttopAPU_EGT:text(limit(egt,0))
		end)
	-- FUEL QUANT
	xpl_dataref_subscribe("sim/flightmodel/weight/m_fuel1", "FLOAT", 
                          "sim/flightmodel/weight/m_fuel2", "FLOAT", 
                          "cl300/fuel_imbalanced",          "INT",
		function(vl, vr, i)
            local l = vl*2.20462262
            local r = vr*2.20462262
            local s = l+r
            local c = (s < 1400 and 3 or (i > 0 and 2 or 1))
			ttopFUEL_L:text(limit(l,0))
			ttopFUEL_R:text(limit(r,0))
			ttopFUEL_SUM:text(limit(s,0))
			ttopFUEL_L:colorindex(c)
			ttopFUEL_R:colorindex(c)
			ttopFUEL_SUM:colorindex(c)
		end)
	-- MACH / SYNC
	xpl_dataref_subscribe("sim/flightmodel/failures/onground_any", 					"INT", 
						  "cl300/engine_state_rpm_l",								"INT",  
						  "cl300/engine_state_rpm_r",								"INT",  
						  "sim/cockpit2/switches/jet_sync_mode", 					"INT", 
						  "cl300/engn_mach_h",										"INT", 	
						  "cl300/carets", 											"INT", 
		function(onground, rpm_l, rpm_r, sync, mach_h, carets)
			local show_sync = onground == 0 and sync > 0 and (mach_h == 0 or carets == 2) and carets < 3 and rpm_l > 0 and rpm_r > 0
			local show_mach = onground == 0 and mach_h > 0 and carets < 2 and rpm_l > 0 and rpm_r > 0
			ttopMACH:showElem(show_mach)
			ttopSYNC:showElem(show_sync)
		end)
	xpl_dataref_subscribe("cl300/engn_mach_status", "INT",
		function(v) 
			ttopMACH:colorindex(v == 1 and 1 or 2)
		end)
end