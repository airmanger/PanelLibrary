local AP_BSRC = 0 -- BRG SRC menu
local AP_OBS1 = 0
local AP_OBS2 = 0
local AP_CRS  = 0
local AP_HDG  = 0
local AP_ALT  = 0
local AP_SPD  = 0
local AP_ISM  = 0 -- IS MACH
local AP_VS   = 0
local AP_VSM  = 0 -- V/S MODE
local AP_PTM  = 0 -- PITCH MODE

xpl_dataref_subscribe("cl300/autop_brgsrc",                                   "INT",   function(v) AP_BSRC = v end)
xpl_dataref_subscribe("sim/cockpit2/radios/actuators/nav1_obs_deg_mag_pilot", "FLOAT", function(v) AP_OBS1 = v end)
xpl_dataref_subscribe("sim/cockpit2/radios/actuators/nav2_obs_deg_mag_pilot", "FLOAT", function(v) AP_OBS2 = v end)
xpl_dataref_subscribe("sim/cockpit2/radios/actuators/hsi_obs_deg_mag_pilot",  "FLOAT", function(v) AP_CRS  = v end)
xpl_dataref_subscribe("sim/cockpit2/autopilot/heading_dial_deg_mag_pilot",    "FLOAT", function(v) AP_HDG  = v end)
xpl_dataref_subscribe("sim/cockpit2/autopilot/altitude_dial_ft",              "FLOAT", function(v) AP_ALT  = v end)
xpl_dataref_subscribe("sim/cockpit2/autopilot/airspeed_dial_kts_mach",        "FLOAT", function(v) AP_SPD  = v end)
xpl_dataref_subscribe("sim/cockpit2/autopilot/airspeed_is_mach",              "INT",   function(v) AP_ISM  = v end)
xpl_dataref_subscribe("sim/cockpit2/autopilot/vvi_dial_fpm",                  "FLOAT", function(v) AP_VS   = v end)
xpl_dataref_subscribe("sim/cockpit2/autopilot/vvi_status",                    "INT",   function(v) AP_VSM  = v end)
xpl_dataref_subscribe("sim/cockpit2/autopilot/pitch_status",                  "INT",   function(v) AP_PTM  = v end)

function var_cap_course(crs)
	crs = var_round(crs, 0)
	if crs < 0 then crs = crs + 360 elseif crs >= 360 then crs = crs - 360 end
	return crs
end

function crs_up()
	if AP_BSRC == 0 then 
		xpl_dataref_write("sim/cockpit2/radios/actuators/nav1_obs_deg_mag_pilot", "FLOAT", var_cap_course(AP_OBS1 + 1))
	elseif AP_BSRC == 1 then 
		xpl_dataref_write("sim/cockpit2/radios/actuators/nav2_obs_deg_mag_pilot", "FLOAT", var_cap_course(AP_OBS2 + 1))
	else
		xpl_dataref_write("sim/cockpit2/radios/actuators/hsi_obs_deg_mag_pilot",  "FLOAT", var_cap_course(AP_CRS + 1))
	end
end
function crs_down()
	if AP_BSRC == 0 then 
		xpl_dataref_write("sim/cockpit2/radios/actuators/nav1_obs_deg_mag_pilot", "FLOAT", var_cap_course(AP_OBS1 - 1))
	elseif AP_BSRC == 1 then 
		xpl_dataref_write("sim/cockpit2/radios/actuators/nav2_obs_deg_mag_pilot", "FLOAT", var_cap_course(AP_OBS2 - 1))
	else
		xpl_dataref_write("sim/cockpit2/radios/actuators/hsi_obs_deg_mag_pilot",  "FLOAT", var_cap_course(AP_CRS - 1))
	end
end

--[[
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

function spd_up()
    local spd
    if AP_ISM > 0 then
        spd = var_round(AP_SPD, 2) + 0.01
    else
        spd = var_round(AP_SPD, 0) + 1
    end
    xpl_dataref_write("sim/cockpit2/autopilot/airspeed_dial_kts_mach", "FLOAT", spd)
end
function spd_down()
    local spd 
    if AP_ISM > 0 then
        spd = var_round(AP_SPD, 2) - 0.01
    else
        spd = var_round(AP_SPD, 0) - 1
    end
    xpl_dataref_write("sim/cockpit2/autopilot/airspeed_dial_kts_mach", "FLOAT", spd)
end
--]]

function alt_up()
    local alt = var_round(AP_ALT / 100, 0) * 100 + 100
    xpl_dataref_write("sim/cockpit2/autopilot/altitude_dial_ft", "FLOAT", alt)
end
function alt_down()
    local alt = var_round(AP_ALT / 100, 0) * 100 - 100
    xpl_dataref_write("sim/cockpit2/autopilot/altitude_dial_ft", "FLOAT", alt)
end

function vvi_up()
    if AP_VSM > 0 then
		local f = math.abs(AP_VS) < 975 and 50 or 100
		local vs = var_round(AP_VS / f, 0) * f + f
        xpl_dataref_write("sim/cockpit2/autopilot/vvi_dial_fpm", "FLOAT", vs)
    elseif AP_PTM > 0 then
        xpl_command("sim/autopilot/nose_up_pitch_mode")
    end
end
function vvi_down()
    if AP_VSM > 0 then
		local f = math.abs(AP_VS) < 975 and 50 or 100
        local vs = var_round(AP_VS / f, 0) * f - f
        xpl_dataref_write("sim/cockpit2/autopilot/vvi_dial_fpm", "FLOAT", vs)
    elseif AP_PTM > 0 then
        xpl_command("sim/autopilot/nose_down_pitch_mode")
    end
end

function clear_master_alerts(phase)
    xpl_command("sim/annunciator/clear_master_warning")
    xpl_command("sim/annunciator/clear_master_caution")
end

function alt_alert_cancel(phase)
    -- if distance to alt > 200 ft while in alt hold, the alt envelope 
    -- should begin to flash on the pfd as alert... this will be cancelled
    -- by this button, but so far the functionality hasn't been implemented.
    if DEBUG then print("altitude hold alert cancel") end
end

CRS_DIAL = ICmd("int/crs_up", "int/crs_down", crs_up, crs_down)
--[[
HDG_DIAL = ICmd("int/hdg_up", "int/hdg_down", hdg_up, hdg_down)
SPD_DIAL = ICmd("int/spd_up", "int/spd_down", spd_up, spd_down)
--]]
HDG_DIAL = XCmd("sim/autopilot/heading_up",  "sim/autopilot/heading_down")
SPD_DIAL = XCmd("sim/autopilot/airspeed_up", "sim/autopilot/airspeed_down")
ALT_DIAL = ICmd("int/alt_up", "int/alt_down", alt_up, alt_down)
VS_WHEEL = ICmd("int/vvi_up", "int/vvi_down", vvi_up, vvi_down)

CLEAR_ALERTS = ICmd("int/clear_master_alerts", nil, clear_master_alerts)
CANCEL_ALT_ALERT = ICmd("int/alt_alert_cancle",nil, alt_alert_cancel)

