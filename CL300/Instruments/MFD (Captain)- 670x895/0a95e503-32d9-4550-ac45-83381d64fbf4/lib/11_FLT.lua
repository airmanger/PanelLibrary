if CAPTAIN then
	local itopSTRIM    = Image.new("stab_trim_s.png",             300,  68, 55, 30, tCONST)
	local ttopSTRIM    = Text.new("0.0", TXT_16B_R , {"#00FF00"}, 300,  74, 48, 18, tCONST) 
	local ttopFLAPS    = Text.new("0",   TXT_16B_L , {"#00FF00"}, 332, 157, 55, 18, tCONST)
	local itopFLAPS    = Image.new("n1_needle.png",               297, 147,  4, 70, tCONST)
	local itopFLAPSREQ = Image.new("blue_arrow_line.png",         296, 138,  6, 88, tCONST)
	local ttopCAB_A    = Text.new("0",   TXT_14B_R , {"#00FF00"}, 395, 358, 45, 14, tCONST)
	local ttopCAB_R    = Text.new("0",   TXT_14B_R , {"#00FF00"}, 395, 374, 45, 14, tCONST)
	local itopCAB_U    = Image.new("arrow_cab_up.png",            383, 360,  5, 32, tOPTIONAL)
	local itopCAB_D    = Image.new("arrow_cab_down.png",          383, 360,  5, 32, tOPTIONAL)
	local itopATRIM    = Image.new("ail_trim_s.png",              393,  59, 42,  6, tCONST)
	local itopRTRIM    = Image.new("rud_trim_s.png",              406, 118, 16, 19, tCONST)
	local itopG_N_GS   = Image.new("gear_dn.png",                 403, 177, 31, 38, tOPTIONAL)
	local itopG_N_WS   = Image.new("gear_up_white.png",           403, 177, 31, 38, tOPTIONAL)
	local itopG_N_RS   = Image.new("gear_up_red.png",             403, 177, 31, 38, tOPTIONAL)
	local itopG_N_WT   = Image.new("gear_trans_white.png",        403, 177, 31, 38, tOPTIONAL)
	local itopG_N_RT   = Image.new("gear_trans_red.png",          403, 177, 31, 38, tOPTIONAL)
	local itopG_L_GS   = Image.new("gear_dn.png",                 369, 192, 31, 38, tOPTIONAL)
	local itopG_L_WS   = Image.new("gear_up_white.png",           369, 192, 31, 38, tOPTIONAL)
	local itopG_L_RS   = Image.new("gear_up_red.png",             369, 192, 31, 38, tOPTIONAL)
	local itopG_L_WT   = Image.new("gear_trans_white.png",        369, 192, 31, 38, tOPTIONAL)
	local itopG_L_RT   = Image.new("gear_trans_red.png",          369, 192, 31, 38, tOPTIONAL)
	local itopG_R_GS   = Image.new("gear_dn.png",                 437, 192, 31, 38, tOPTIONAL)
	local itopG_R_WS   = Image.new("gear_up_white.png",           437, 192, 31, 38, tOPTIONAL)
	local itopG_R_RS   = Image.new("gear_up_red.png",             437, 192, 31, 38, tOPTIONAL)
	local itopG_R_WT   = Image.new("gear_trans_white.png",        437, 192, 31, 38, tOPTIONAL)
	local itopG_R_RT   = Image.new("gear_trans_red.png",          437, 192, 31, 38, tOPTIONAL)

	xpl_dataref_subscribe("sim/flightmodel2/controls/elevator_trim", "FLOAT",
		function(v) 
			ttopSTRIM:text(limit((v/2+0.5)*15, 1))
			ttopSTRIM:moverel(0, -v*43)
			itopSTRIM:moverel(0, -v*43)
		end)
	xpl_dataref_subscribe("sim/flightmodel/controls/flaprat",							"FLOAT", function(v) ttopFLAPS:text(limit(v * 30, 0)) itopFLAPS:rotate(v*90+90) end)
	xpl_dataref_subscribe("sim/flightmodel/controls/flaprqst",							"FLOAT", function(v) itopFLAPSREQ:rotate(v*90+90) end)
	xpl_dataref_subscribe("sim/cockpit2/pressurization/indicators/cabin_altitude_ft",	"FLOAT", function(v) ttopCAB_A:text(limit(v, 0)) end)
	xpl_dataref_subscribe("sim/cockpit2/pressurization/indicators/cabin_vvi_fpm",		"FLOAT", function(v) ttopCAB_R:text(limit(v, 0)) itopCAB_U:showElem(v>10) itopCAB_D:showElem(v<-10) end)
	xpl_dataref_subscribe("sim/flightmodel2/controls/aileron_trim", "FLOAT", function(v) itopATRIM:rotate(v * 60) end)
	xpl_dataref_subscribe("sim/flightmodel2/controls/rudder_trim",  "FLOAT", function(v) itopRTRIM:moverel(v * 30, 0) end)
	xpl_dataref_subscribe("sim/flightmodel2/gear/deploy_ratio", "FLOAT[10]", 
						  "sim/operation/failures/rel_lagear1", "INT", 
						  "sim/operation/failures/rel_lagear2", "INT", 
						  "sim/operation/failures/rel_lagear3", "INT", 
		function(d, f1, f2, f3) 
			itopG_N_GS:showElem(d[1] == 1)
			itopG_N_WS:showElem(d[1] == 0             and f1 ~= 6)
			itopG_N_RS:showElem(d[1] == 0             and f1 == 6)
			itopG_N_WT:showElem(d[1] > 0 and d[1] < 1 and f1 ~= 6)
			itopG_N_RT:showElem(d[1] > 0 and d[1] < 1 and f1 == 6)
			itopG_L_GS:showElem(d[2] == 1)
			itopG_L_WS:showElem(d[2] == 0             and f2 ~= 6)
			itopG_L_RS:showElem(d[2] == 0             and f2 == 6)
			itopG_L_WT:showElem(d[2] > 0 and d[2] < 1 and f2 ~= 6)
			itopG_L_RT:showElem(d[2] > 0 and d[2] < 1 and f2 == 6)
			itopG_R_GS:showElem(d[3] == 1)
			itopG_R_WS:showElem(d[3] == 0             and f3 ~= 6)
			itopG_R_RS:showElem(d[3] == 0             and f3 == 6)
			itopG_R_WT:showElem(d[3] > 0 and d[3] < 1 and f3 ~= 6)
			itopG_R_RT:showElem(d[3] > 0 and d[3] < 1 and f3 == 6)
		end)

	-- speedbrake/spoiler symbols
	local itopSPLR_L_Yi  = Image.new("sbrake1_yellow.png", 305, 305, 21, 9, tGROUPED)
	local itopSPLR_L_Gi  = Image.new("sbrake1_green.png",  305, 305, 21, 9, tGROUPED)
	local itopSBRK_L_Yi  = Image.new("sbrake1_yellow.png", 336, 305, 21, 9, tGROUPED)
	local itopSBRK_L_Gi  = Image.new("sbrake1_green.png",  336, 305, 21, 9, tGROUPED)
	local itopSBRK_R_Yi  = Image.new("sbrake1_yellow.png", 385, 305, 21, 9, tGROUPED)
	local itopSBRK_R_Gi  = Image.new("sbrake1_green.png",  385, 305, 21, 9, tGROUPED)
	local itopSPLR_R_Yi  = Image.new("sbrake1_yellow.png", 416, 305, 21, 9, tGROUPED)
	local itopSPLR_R_Gi  = Image.new("sbrake1_green.png",  416, 305, 21, 9, tGROUPED)
	local gtopSPLR_Yi    = Group.new({itopSPLR_L_Yi, itopSBRK_L_Yi, itopSBRK_R_Yi, itopSPLR_R_Yi}, tOPTIONAL)
	local gtopSPLR_Gi    = Group.new({itopSPLR_L_Gi, itopSBRK_L_Gi, itopSBRK_R_Gi, itopSPLR_R_Gi}, tOPTIONAL)
	xpl_dataref_subscribe("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1", "FLOAT", function(v) gtopSPLR_Yi:showElem(v < 10) gtopSPLR_Gi:showElem(v >= 10) end)

	-- speedbrake/spoiler lines & arrows
	local itopSPLR_LL_l  = Image.new("green_line.png",  310, 300,  2, 5, tOPTIONAL)
	local itopSPLR_LR_l  = Image.new("green_line.png",  318, 300,  2, 5, tOPTIONAL)
	local itopSBRK_LL_l  = Image.new("green_line.png",  341, 300,  2, 5, tOPTIONAL)
	local itopSBRK_LR_l  = Image.new("green_line.png",  349, 300,  2, 5, tOPTIONAL)
	local itopSBRK_RL_l  = Image.new("green_line.png",  390, 300,  2, 5, tOPTIONAL)
	local itopSBRK_RR_l  = Image.new("green_line.png",  398, 300,  2, 5, tOPTIONAL)
	local itopSPLR_RL_l  = Image.new("green_line.png",  421, 300,  2, 5, tOPTIONAL)
	local itopSPLR_RR_l  = Image.new("green_line.png",  429, 300,  2, 5, tOPTIONAL)
	local itopSPLR_LL_a  = Image.new("arrow_line2.png", 304, 304,  8, 7, tOPTIONAL)
	local itopSPLR_LR_a  = Image.new("arrow_line.png",  318, 304,  8, 7, tOPTIONAL)
	local itopSBRK_LL_a  = Image.new("arrow_line2.png", 335, 304,  8, 7, tOPTIONAL)
	local itopSBRK_LR_a  = Image.new("arrow_line.png",  349, 304,  8, 7, tOPTIONAL)
	local itopSBRK_RL_a  = Image.new("arrow_line2.png", 384, 304,  8, 7, tOPTIONAL)
	local itopSBRK_RR_a  = Image.new("arrow_line.png",  398, 304,  8, 7, tOPTIONAL)
	local itopSPLR_RL_a  = Image.new("arrow_line2.png", 415, 304,  8, 7, tOPTIONAL)
	local itopSPLR_RR_a  = Image.new("arrow_line.png",  429, 304,  8, 7, tOPTIONAL)

	xpl_dataref_subscribe("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1", "FLOAT", 
						  "sim/flightmodel2/wing/spoiler1_deg",    "FLOAT[32]", 
		function(p,s1) 
			-- outer left spoiler
			if p < 5 or s1[1] < 0.91 then
				itopSPLR_LL_l:showElem(false) 
				itopSPLR_LL_a:showElem(false)
			else
				itopSPLR_LL_l:showElem(true) 
				itopSPLR_LL_a:showElem(true)
				itopSPLR_LL_l:resize( 0, 5-s1[1]*1.2, 2, s1[1]*1.2)
				itopSPLR_LL_a:moverel(0,  -s1[1]*1.2)
			end
			-- outer right spoiler
			if p < 5 or s1[2] < 0.91 then
				itopSPLR_RR_l:showElem(false) 
				itopSPLR_RR_a:showElem(false)
			else
				itopSPLR_RR_l:showElem(true) 
				itopSPLR_RR_a:showElem(true)
				itopSPLR_RR_l:resize( 0, 5-s1[2]*1.2, 2, s1[2]*1.2)
				itopSPLR_RR_a:moverel(0,  -s1[2]*1.2)
			end
		end)

	xpl_dataref_subscribe("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1", "FLOAT", 
						  "sim/flightmodel2/wing/spoiler2_deg",    "FLOAT[32]", 
		function(p,s2) 
			-- inner left spoiler
			if p < 5 or s2[1] < 0.91 then
				itopSPLR_LR_l:showElem(false) 
				itopSPLR_LR_a:showElem(false)
			else
				itopSPLR_LR_l:showElem(true) 
				itopSPLR_LR_a:showElem(true)
				itopSPLR_LR_l:resize( 0, 5-s2[1]*1.2, 2, s2[1]*1.2)
				itopSPLR_LR_a:moverel(0,  -s2[1]*1.2)
			end
			-- inner right spoiler
			if p < 5 or s2[2] < 0.91 then
				itopSPLR_RL_l:showElem(false) 
				itopSPLR_RL_a:showElem(false)
			else
				itopSPLR_RL_l:showElem(true) 
				itopSPLR_RL_a:showElem(true)
				itopSPLR_RL_l:resize( 0, 5-s2[2]*1.2, 2, s2[2]*1.2)
				itopSPLR_RL_a:moverel(0,  -s2[2]*1.2)
			end
		end)

	xpl_dataref_subscribe("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1", "FLOAT", 
						  "sim/flightmodel2/wing/speedbrake1_deg", "FLOAT[32]", 
		function(p,sb) 
			-- left speedbrakes
			if p < 5 or sb[1] < 1.12 then
				itopSBRK_LL_l:showElem(false) 
				itopSBRK_LL_a:showElem(false)
				itopSBRK_LR_l:showElem(false) 
				itopSBRK_LR_a:showElem(false)
			else
				itopSBRK_LL_l:showElem(true) 
				itopSBRK_LL_a:showElem(true)
				itopSBRK_LR_l:showElem(true) 
				itopSBRK_LR_a:showElem(true)
				itopSBRK_LL_l:resize( 0, 5-sb[1]*0.9, 2, sb[1]*0.9)
				itopSBRK_LL_a:moverel(0,  -sb[1]*0.9)
				itopSBRK_LR_l:resize( 0, 5-sb[1]*0.9, 2, sb[1]*0.9)
				itopSBRK_LR_a:moverel(0,  -sb[1]*0.9)
			end
			-- right speedbrakes
			if p < 5 or sb[2] < 1.12 then
				itopSBRK_RL_l:showElem(false) 
				itopSBRK_RL_a:showElem(false)
				itopSBRK_RR_l:showElem(false) 
				itopSBRK_RR_a:showElem(false)
			else
				itopSBRK_RL_l:showElem(true) 
				itopSBRK_RL_a:showElem(true)
				itopSBRK_RR_l:showElem(true) 
				itopSBRK_RR_a:showElem(true)
				itopSBRK_RL_l:resize( 0, 5-sb[2]*0.9, 2, sb[2]*0.9)
				itopSBRK_RL_a:moverel(0,  -sb[2]*0.9)
				itopSBRK_RR_l:resize( 0, 5-sb[2]*0.9, 2, sb[2]*0.9)
				itopSBRK_RR_a:moverel(0,  -sb[2]*0.9)
			end
		end)

	-- hide spoilers
	local itopSBRK_HIDE = Image.new("black.png", 270, 155, 200, 180, tCONST)
	local SBRK_HIDE = false
	function sbrk_timer() if SBRK_HIDE then itopSBRK_HIDE:showElem(true) end end
	-- show/hide APU INFO
	xpl_dataref_subscribe("sim/flightmodel/failures/onground_any", 		"INT",
						  "sim/cockpit/switches/gear_handle_status",	"INT",
						  "sim/flightmodel/controls/flaprqst",			"FLOAT",
						  "cl300/sbrk_h",								"FLOAT",
		function(gnd, gear, flaps, sbrk) 
			SBRK_HIDE = (gnd + gear + flaps) == 0 and sbrk < 0.03 
			if SBRK_HIDE then timer_start(30000,nil,sbrk_timer) 
			else itopSBRK_HIDE:showElem(false) end 
		end)
end