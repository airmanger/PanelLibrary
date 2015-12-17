
txt_load_font("Vera.ttf")
txt_load_font("VeraBd.ttf")

local FRAME = img_add("FRAME.png", 220, 107, 230, 231)
local HEAD   = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:15px; -fx-font-weight:bold; -fx-text-alignment:left;   -fx-fill: #CCCCCC;"
local ITEM_L = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:14px; -fx-font-weight:bold; -fx-text-alignment:left;   -fx-fill: "
local ITEM_C = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:14px; -fx-font-weight:bold; -fx-text-alignment:center; -fx-fill: "
local ITEM_R = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:14px; -fx-font-weight:bold; -fx-text-alignment:right;  -fx-fill: "


-- ***** NAV SRC **********************************************
local nav_bg = img_add("BOX_MENU.png", 20, 80, 105, 25)
local nav_hd = txt_add("NAV SRC", HEAD, 26, 85, 85, 15)
local nav_txt = {txt_add("FMS",  ITEM_L .. "#00FFFF", 26, 111, 45, 14),
				 txt_add("NAV1", ITEM_L .. "#00FFFF", 26, 131, 45, 14),
				 txt_add("NAV2", ITEM_L .. "#00FFFF", 26, 151, 45, 14)}
local nav_box = img_add("BOX_REFS.png", 19, 109, 52, 22)
local nav_grp = group_add(nav_bg, nav_hd, nav_txt[1], nav_txt[2], nav_txt[3], nav_box)

function show_navsrc(val) 
	if val < 0 then
		visible(nav_grp, false) 
	else
		visible(nav_grp, true)
		for i = 1,3 do
			txt_style(nav_txt[i], ITEM_L .. (i == val+1 and "#FF00FF;" or "#00FFFF;"))
		end
		move(nav_box, 19, 109 + 20*val, 52, 22)
	end
end

xpl_dataref_subscribe("cl300/dcp_navsrc", "INT", show_navsrc)

-- ***** REFS / BRG SRC **********************************************
local ref_bg = img_add("BOX_MENU.png", 20, 180, 105, 25)
local ref_hd = txt_add("REFS", HEAD, 26, 185, 85, 15)
local ref_tl = {txt_add("", ITEM_L .. "#CCCCCC", 26, 211, 45, 17),
				txt_add("", ITEM_L .. "#CCCCCC", 26, 231, 45, 17),
				txt_add("", ITEM_L .. "#CCCCCC", 26, 251, 45, 17),
				txt_add("", ITEM_L .. "#CCCCCC", 26, 271, 45, 17),
				txt_add("", ITEM_L .. "#CCCCCC", 26, 291, 45, 17),
				txt_add("", ITEM_L .. "#CCCCCC", 26, 311, 45, 17)}
local ref_tr = {txt_add("", ITEM_C .. "#00FFFF", 76, 211, 48, 14),
				txt_add("", ITEM_C .. "#00FFFF", 76, 231, 48, 14),
				txt_add("", ITEM_C .. "#00FFFF", 76, 251, 48, 14),
				txt_add("", ITEM_C .. "#00FFFF", 76, 271, 48, 14),
				txt_add("", ITEM_C .. "#00FFFF", 76, 291, 48, 14),
				txt_add("", ITEM_C .. "#00FFFF", 76, 311, 48, 14)}
local ref_box = img_add("BOX_REFS.png", 74, 209, 52, 22)
local ref_grp = group_add(ref_bg, ref_hd, ref_tl[1], ref_tl[2], ref_tl[3], ref_tl[4], ref_tl[5], ref_tl[6], 
						                  ref_tr[1], ref_tr[2], ref_tr[3], ref_tr[4], ref_tr[5], ref_tr[6], ref_box)

visible(ref_grp, false)

local last_ref = -1
function show_refs(brg, ref, refmen, src1, obs1, src2, obs2, v1, vr, v2, vt, vga, vref, ra, da, rada, baro, arpt, wpt, vor, ndb, pos, dat)
	
	if last_ref ~= (brg > -1 and 9 or ref) then
		visible(ref_grp, brg > -1 or ref > -1)
	end
		
	if brg > -1 then
		if last_ref ~= 9 then 
			txt_set(ref_hd, "BRG SRC")
			txt_set(ref_tl[1], "OBS1")
			txt_set(ref_tl[2], "")
			txt_set(ref_tl[3], "OBS2")
			txt_set(ref_tl[4], "")
			txt_set(ref_tl[5], "")
			txt_set(ref_tl[6], "")
			txt_set(ref_tr[5], "")
			txt_set(ref_tr[6], "")
		end
		
		txt_set(ref_tr[1], src1 > 0 and "NAV1" or "ADF1")
		txt_set(ref_tr[2], string.format("%03d", obs1))
		txt_set(ref_tr[3], src2 > 0 and "NAV2" or "ADF2")
		txt_set(ref_tr[4], string.format("%03d", obs2))
		
		move(ref_box, 74, 209+40*brg, 52, 22)
		
	elseif ref > -1 then
		
		if last_ref ~= ref then
			txt_set(ref_hd, "REFS")
			if ref == 0 then -- T/O Vspds
				txt_set(ref_tl[1], "V1")	txt_set(ref_tl[2], "Vr")	txt_set(ref_tl[3], "V2")
				txt_set(ref_tl[4], "")		txt_set(ref_tl[5], "")		txt_set(ref_tl[6], "")
				txt_set(ref_tr[4], "")		txt_set(ref_tr[5], "")		txt_set(ref_tr[6], "")
			elseif ref == 1 then -- APP Vspds
				txt_set(ref_tl[1], "Vt")	txt_set(ref_tl[2], "Vga")	txt_set(ref_tl[3], "Vref")
				txt_set(ref_tl[4], "")		txt_set(ref_tl[5], "")		txt_set(ref_tl[6], "")
				txt_set(ref_tr[4], "")		txt_set(ref_tr[5], "")		txt_set(ref_tr[6], "")
			elseif ref == 2 then -- Mins
				txt_set(ref_tl[1], "MIN")	txt_set(ref_tl[2], "")		txt_set(ref_tl[3], "")
				txt_set(ref_tl[4], "")		txt_set(ref_tl[5], "")		txt_set(ref_tl[6], "")
				txt_set(ref_tr[3], "")		txt_set(ref_tr[4], "")		txt_set(ref_tr[5], "")		txt_set(ref_tr[6], "")
			elseif ref == 3 then -- Baro
				txt_set(ref_tl[1], "BARO")	txt_set(ref_tl[2], "")		txt_set(ref_tl[3], "")
				txt_set(ref_tl[4], "")		txt_set(ref_tl[5], "")		txt_set(ref_tl[6], "")
				txt_set(ref_tr[2], "")		txt_set(ref_tr[3], "")		txt_set(ref_tr[4], "")
				txt_set(ref_tr[5], "")		txt_set(ref_tr[6], "")
			elseif ref == 4 then -- MAP
				txt_set(ref_tl[1], "ARPT")	txt_set(ref_tl[2], "WPT")	txt_set(ref_tl[3], "VOR")
				txt_set(ref_tl[4], "NDB")	txt_set(ref_tl[5], "POS")	txt_set(ref_tl[6], "DATA")
			end
		end
		
		if ref == 0 then -- T/O Vspds
			txt_set(ref_tr[1], v1)			txt_set(ref_tr[2], vr)		txt_set(ref_tr[3], v2)
		elseif ref == 1 then -- APP Vspds
			txt_set(ref_tr[1], vt)			txt_set(ref_tr[2], vga)		txt_set(ref_tr[3], vref)
		elseif ref == 2 then -- Mins
            if rada > 0 then
                txt_set(ref_tr[1], string.format("%d", da))				txt_set(ref_tr[2], "DA")
            else
                txt_set(ref_tr[1], string.format("%d", ra))				txt_set(ref_tr[2], "RA")
            end
		elseif ref == 3 then -- Baro
			txt_set(ref_tr[1], baro > 0 and "hPa" or "IN")
		elseif ref == 4 then -- MAP
			txt_set(ref_tr[1], arpt > 0 and "YES" or "NO")		txt_set(ref_tr[2], wpt > 0 and "YES" or "NO")	txt_set(ref_tr[3], vor > 0 and "YES" or "NO")
			txt_set(ref_tr[4], ndb > 0 and "YES" or "NO")		txt_set(ref_tr[5], pos > 0 and "YES" or "NO")	txt_set(ref_tr[6], dat > 0 and "YES" or "NO")
		end	

		move(ref_box, 74, 209+20*refmen, 52, 22)
	end

	last_ref = brg > -1 and 9 or ref
end

xpl_dataref_subscribe(  "cl300/autop_brgsrc", 											"INT", 
						"cl300/dcp_refs", 												"INT", 
						"cl300/dcp_refs_menu", 											"INT", 
						-- brg src
						"sim/cockpit2/EFIS/EFIS_1_selection_pilot", 					"INT",
						"sim/cockpit/radios/nav1_obs_degm", 							"FLOAT",
						"sim/cockpit2/EFIS/EFIS_2_selection_pilot", 					"INT",
						"sim/cockpit/radios/nav2_obs_degm", 							"FLOAT",
						-- ref spds
						"cl300/refspds_v1", 											"INT", 
						"cl300/refspds_vr", 											"INT", 
						"cl300/refspds_v2", 											"INT", 
						"cl300/refspds_vt", 											"INT", 
						"cl300/refspds_vga", 											"INT", 
						"cl300/refspds_vref", 											"INT", 
						-- mins page
						"sim/cockpit2/gauges/actuators/radio_altimeter_bug_ft_pilot", 	"FLOAT",
						"xhsi/pfd_pilot/da_bug", 	                                    "FLOAT",
						"xhsi/pfd_pilot/mins_mode", 	                                "INT",
						-- baro page
						"cl300/baro_pref", 												"INT", 
						-- map data 
						"sim/cockpit/switches/EFIS_shows_airports", 					"INT", 
						"sim/cockpit/switches/EFIS_shows_waypoints", 					"INT", 
						"sim/cockpit/switches/EFIS_shows_VORs", 						"INT", 
						"sim/cockpit/switches/EFIS_shows_NDBs", 						"INT", 
						"xhsi/nd_pilot/pos", 											"INT", 
						"xhsi/nd_pilot/data", 											"INT",
						show_refs)


-- ***** AUTOPILOT **********************************************
local ap_bg = img_add("BOX_AP.png",                207,  5, 256, 40)
local ap_ap = txt_add("AP",   ITEM_L .. "#FF0000", 312,  6,  46, 15)
local ap_yd = txt_add("YD",   ITEM_R .. "#00FF00", 312,  6,  46, 15)
local ap_bk = txt_add("", 	  ITEM_L .. "#00FF00", 209,  6,  97, 15)
local ap_l1 = txt_add("", 	  ITEM_R .. "#00FF00", 209,  6,  97, 15)
local ap_l2 = txt_add("", 	  ITEM_R .. "#CCCCCC", 209, 26,  97, 15)
local ap_r1 = txt_add("",  	  ITEM_L .. "#00FF00", 364,  6,  97, 15)
local ap_r2 = txt_add("", 	  ITEM_L .. "#CCCCCC", 364, 26,  97, 15)
local ap_md = group_add(ap_bk, ap_l1, ap_l2, ap_r1, ap_r2)

function show_ap(servos_on, autopilot_disconnect) 
	if servos_on == 1 then 
		visible(ap_ap, true) 
		txt_style(ap_ap, ITEM_L .. "#00FF00") 
	elseif autopilot_disconnect > 0 then
		visible(ap_ap, true) 
		txt_style(ap_ap, ITEM_L .. "#FF0000") 
	else
		visible(ap_ap, false)
	end
end
xpl_dataref_subscribe(  "sim/cockpit2/autopilot/servos_on",							"INT", 
						"sim/cockpit/warnings/annunciators/autopilot_disconnect",	"INT", 
						show_ap)

						
function show_yd(yaw_damper_on) 
	visible(ap_yd, yaw_damper_on == 1)
end
xpl_dataref_subscribe("sim/cockpit2/switches/yaw_damper_on",	"INT", show_yd)

function show_modes(autopilot_on)
	visible(ap_md, autopilot_on > 0)
end
xpl_dataref_subscribe("sim/cockpit2/autopilot/autopilot_on",	"INT", show_modes)

function show_bk(roll_status, bank_angle_mode) 
	if bank_angle_mode > 0 and roll_status == 0 then
		txt_set(ap_bk, "½BNK")
	else
		txt_set(ap_bk, "")
	end
end
xpl_dataref_subscribe(  "sim/cockpit2/autopilot/roll_status",		"INT", 
						"sim/cockpit2/autopilot/bank_angle_mode",	"INT", 
						show_bk)

function show_l1(roll_status, backcourse_status, TOGA_lateral_status, heading_status, nav_status, HSI_source_select_pilot) 
	if  roll_status > 0 then
		txt_set(ap_l1, "ROLL") 
	elseif backcourse_status == 2 then
		txt_set(ap_l1, "B/C") 
	elseif TOGA_lateral_status > 0 then
		txt_set(ap_l1, "TO") 
	elseif heading_status == 2 then
		txt_set(ap_l1, "HDG") 
	elseif nav_status == 2 then
		if HSI_source_select_pilot == 1 then
			txt_set(ap_l1, "LOC2") 
		elseif HSI_source_select_pilot == 2 then
			txt_set(ap_l1, "FMS1") 
		else
			txt_set(ap_l1, "LOC1") 
		end
	else
		txt_set(ap_l1, "") 
	end
end
xpl_dataref_subscribe(  "sim/cockpit2/autopilot/roll_status",						"INT", 
						"sim/cockpit2/autopilot/backcourse_status",					"INT", 
						"sim/cockpit2/autopilot/TOGA_lateral_status",				"INT", 
						"sim/cockpit2/autopilot/heading_status",					"INT", 
						"sim/cockpit2/autopilot/nav_status",						"INT", 
						"sim/cockpit2/radios/actuators/HSI_source_select_pilot",	"INT", 
						show_l1)

function show_l2(backcourse_status, approach_status, nav_status, HSI_source_select_pilot) 
	if backcourse_status == 1 then
		txt_set(ap_l2, "B/C") 
	elseif approach_status == 1 then
		txt_set(ap_l2, "APPR") 
	elseif nav_status == 1 then
		if HSI_source_select_pilot > 0 then
			txt_set(ap_l2, "LNV2") 
		else
			txt_set(ap_l2, "LNV1") 
		end
	else
		txt_set(ap_l2, "") 
	end
end
xpl_dataref_subscribe(  "sim/cockpit2/autopilot/backcourse_status",					"INT", 
						"sim/cockpit2/autopilot/approach_status",					"INT", 
						"sim/cockpit2/autopilot/nav_status",						"INT", 
						"sim/cockpit2/radios/actuators/HSI_source_select_pilot",	"INT", 
						show_l2)

function show_r1(pitch_status, speed_status, altitude_hold_status, TOGA_status, vvi_status, vvi_dial_fpm, glideslope_status) 
	if pitch_status > 0 then
		txt_set(ap_r1, "PTCH") 
	elseif speed_status > 0 then
		txt_set(ap_r1, "FLC") 
	elseif altitude_hold_status > 1 then
		txt_set(ap_r1, "ALT") 
	elseif TOGA_status > 0 then
		txt_set(ap_r1, "TO") 
	elseif vvi_status > 0  then
		if vvi_dial_fpm == 0 then
			txt_set(ap_r1, "VS") 
		else
			txt_set(ap_r1, "VS     " .. math.floor(vvi_dial_fpm))
		end
	elseif glideslope_status == 2 then
		txt_set(ap_r1, "GS") 
	else
		txt_set(ap_r1, "") 
	end
end
xpl_dataref_subscribe(  "sim/cockpit2/autopilot/pitch_status",						"INT", 
						"sim/cockpit2/autopilot/speed_status",						"INT", 
						"sim/cockpit2/autopilot/altitude_hold_status",				"INT", 
						"sim/cockpit2/autopilot/TOGA_status",						"INT", 
						"sim/cockpit2/autopilot/vvi_status",						"INT", 
						"sim/cockpit2/autopilot/vvi_dial_fpm",						"INT", 
						"sim/cockpit2/autopilot/glideslope_status",					"INT", 
						show_r1)

function show_r2(glideslope_status, altitude_hold_armed) 
	if glideslope_status == 1 then
		txt_set(ap_r2, "GS") 
	elseif altitude_hold_armed == 1 then
		txt_set(ap_r2, "ALTS") 
	else
		txt_set(ap_r2, "") 
	end
end
xpl_dataref_subscribe(  "sim/cockpit2/autopilot/glideslope_status",					"INT", 
						"sim/cockpit2/autopilot/altitude_hold_armed",				"INT", 
						show_r2)

-- ***** BRIGHTNESS **********************************************
CAPTAIN = (instrument_prop("TYPE"):find("First Officer") == nil)
BUS     = (CAPTAIN and 1 or 2)
BRIGHT  = "cl300/" .. (CAPTAIN and "p" or "c") .. "pfd_h"

local iBLK    = img_add_fullscreen("black.png")
local iBRIGHT = {img_add_fullscreen("black_60.png"),
                 img_add_fullscreen("black_50.png"),
                 img_add_fullscreen("black_40.png"),
                 img_add_fullscreen("black_30.png"),
                 img_add_fullscreen("black_20.png"),
                 img_add_fullscreen("black_10.png")}

-- black displays if there's no bus power:
xpl_dataref_subscribe("sim/cockpit2/electrical/bus_volts", "FLOAT[6]", function(v) visible(iBLK, v[BUS] < 10) end)

-- dim displays
xpl_dataref_subscribe(BRIGHT, "FLOAT", function(v) 
    local s = 1 + math.floor(v * 6 + 0.5)
    for i = 1,6 do
        visible(iBRIGHT[i], s == i)
    end
end)
