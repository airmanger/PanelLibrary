-- ******************************************** --
-- Standby attitude indicator Challenger 300    --
-- Based on 737 Instrument by Sim Innovations   --
-- ******************************************** --

-- Load font --
txt_load_font("gadugi.ttf")

-- Add images --
img_horizon_back = img_add("horizonbackground.png", -115, -273, 800, 1200)
img_horizon_numb = img_add("horizonnumbers.png", 149, -673, 272, 2000)
viewport_rect(img_horizon_numb, 105, 154, 360, 367)
img_bank_indicat = img_add("bankindicator.png", 75, 122, 420, 420)
viewport_rect(img_bank_indicat, 105, 90, 360, 182)

img_add_fullscreen("viewport.png")
img_compass = img_add("compass.png", -215, 534, 1000, 1000)
img_add_fullscreen("altspeedtape.png")

-- Heading
txt_heading = txt_add(" ", "-fx-font-size:52px; -fx-font-family:Gadugi; -fx-fill: #FF00FF; -fx-text-alignment:left;", 110, 6, 150, 100)

-- Mach Speed
-- txt_machspd = txt_add("M .74", "-fx-font-size:52px; -fx-font-family:Gadugi; -fx-fill: #00FF00; -fx-text-alignment:right;", 110, 520, 150, 100)

-- Barometric pressure
txt_pressure = txt_add(" ", "-fx-font-size:52px; -fx-font-family:Gadugi; -fx-fill: #00FFFF; -fx-text-alignment:right;", 300, 6, 160, 100)

-- BEGIN Running text and images for speed and altitude
function item_value_callback_speed(i)
    return string.format("%d", 0 - (i * 20) )
end

running_text_speed = running_txt_add_ver(-13,-222,10,100,102,item_value_callback_speed,"-fx-font-size:52px; -fx-font-family:Gadugi; -fx-fill:white; -fx-text-alignment:right;")
running_img_speed  = running_img_add_ver("speedimage.png",78,-30,10,22,102)

running_img_move_carot(running_img_speed, 0)
running_txt_move_carot(running_text_speed, 0)

function item_value_callback_alt(i)
	return string.format("%d", i * 200 * -1 )
end

running_text_alt = running_txt_add_ver(467,-202,8,130,124,item_value_callback_alt,"-fx-font-size:46px; -fx-font-family:Gadugi; -fx-fill:white; -fx-text-alignment:right;")
running_img_alt  = running_img_add_ver("altimage.png",470,-107,8,26,124)

running_img_move_carot(running_img_alt, 0)
running_txt_move_carot(running_text_alt, 0)
-- END Running text and images for speed and altitude

img_add_fullscreen("altspeedbox.png")

-- BEGIN Running text airspeed --
function item_value_callback_inner_speed_minor(i)
    
	if i > 0 then
		return""
	else
		return string.format("%d", (0 - i) % 10 )
	end
	
end

running_text_inner_speed_minor_id = running_txt_add_ver(68,149,5,80,67, item_value_callback_inner_speed_minor, "-fx-font-size:60px; -fx-font-family:Gadugi; -fx-font-weight:bold; -fx-fill:#00FF00;")
running_txt_move_carot(running_text_inner_speed_minor_id, 0)

running_txt_viewport_rect(running_text_inner_speed_minor_id,0,287,103,80)

function item_value_callback_inner_speed_major(i)
    
	if i == 0 then
		return ""
	else
		return string.format("%d", (0 - i) )
	end
	
end

running_text_inner_speed_major_id = running_txt_add_ver(-11,216,3,80,67, item_value_callback_inner_speed_major, "-fx-font-size:60px; -fx-font-family:Gadugi; -fx-fill:#00FF00; -fx-font-weight:bold; -fx-text-alignment:right")
running_txt_move_carot(running_text_inner_speed_major_id, 0)

running_txt_viewport_rect(running_text_inner_speed_major_id,0,287,103,80)
-- END Running text airspeed --

-- BEGIN Running text altitude --
function item_value_callback_inner_alt_minor(i)
	
	if i == 0 then
		return"0"
	elseif i > 0 then
		return""
	else
		return string.format("%02d", ((0-i)%10) * 10 )
	end
	
end

running_text_inner_alt_minor_id = running_txt_add_ver(498,168,5,100,60, item_value_callback_inner_alt_minor, "-fx-font-size:52px; -fx-font-family:Gadugi; -fx-fill:#00FF00; -fx-font-weight:bold; -fx-text-alignment:right")
running_txt_move_carot(running_text_inner_alt_minor_id, 0)
running_txt_viewport_rect(running_text_inner_alt_minor_id,435,288,166,80)


function item_value_callback_inner_alt_major100(i)
    
	if i == 0 then
		return""
	else
		return string.format("%d", (0 - i)%10 )
	end
	
end

running_text_inner_alt_major100_id = running_txt_add_ver(490,228,3,50,60, item_value_callback_inner_alt_major100, "-fx-font-size:52px; -fx-font-family:Gadugi; -fx-fill:#00FF00; -fx-font-weight:bold; -fx-text-alignment:right")
running_txt_move_carot(running_text_inner_alt_major100_id, 0)
running_txt_viewport_rect(running_text_inner_alt_major100_id,435,288,166,80)

function item_value_callback_inner_alt_major1000(i)

	if i == 0 then
		return""
	else
		return"" .. - i
	end
	
end

running_text_inner_alt_major1000_id = running_txt_add_ver(404,203,3,103,80, item_value_callback_inner_alt_major1000, "-fx-font-size:60px; -fx-font-family:Gadugi; -fx-fill:#00FF00; -fx-font-weight:bold; -fx-text-alignment:right")
running_txt_move_carot(running_text_inner_alt_major1000_id, 0)
running_txt_viewport_rect(running_text_inner_alt_major1000_id,435,288,166,80)
-- END Running text altitude --

-- Functions --
function new_data(heading, roll, pitch, airspeed, altitude)

    -- Rotate the roll indicator (electric gyro)
    img_rotate(img_bank_indicat, roll)

    -- Roll the horizon (electric gyro)
    img_rotate(img_horizon_back, roll * -1)
    img_rotate(img_horizon_numb, roll * -1)
    
    -- Move the horizon pitch, background and numbers seperately (electric gyro)
    pitch_back = var_cap(pitch, -29, 29)
    pitch_numb = var_cap(pitch, -90, 90)
    radial = math.rad(roll * -1)
    
    x_b = -(math.sin(radial) * pitch_back * 10)
    y_b = (math.cos(radial) * pitch_back * 10)
    x_n = -(math.sin(radial) * pitch_numb * 10)
    y_n = (math.cos(radial) * pitch_numb * 10)
    
    img_move(img_horizon_back, x_b - 115, y_b - 273, nil, nil)
    img_move(img_horizon_numb, x_n + 149, y_n - 673, nil, nil)
    
    -- Speed box running text and images
    -- Cap the airspeed at 999 knots maximum displayed
    airspeed = var_cap(airspeed, 0, 999)
    
    running_txt_move_carot(running_text_inner_speed_minor_id, (airspeed / 1) * -1)

    if airspeed % 10 > 9 then
    	running_txt_move_carot(running_text_inner_speed_major_id, ( airspeed - 9 - (math.floor(airspeed / 10) * 9) ) * -1 )
    else
    	running_txt_move_carot(running_text_inner_speed_major_id, math.floor(airspeed / 10) * -1)
    end

	running_txt_move_carot(running_text_speed, (airspeed / 20) * -1)
    running_img_move_carot(running_img_speed, (airspeed / 20) * -1)    
    
	yspeed = 342 + (airspeed * 5.86)
	yspeed = var_cap(yspeed, 327, 600)
	
	viewport_rect(running_text_speed, 0, 0, 100, yspeed)
	viewport_rect(running_img_speed, 0, 0, 100, yspeed)    
    
    -- Altitude indicator running text and images
    -- Cap the altitude at 90.400 ft maximum displayed
    altitude = var_cap(altitude, 0, 90400)
    
	running_txt_move_carot(running_text_inner_alt_minor_id, (altitude / 10) * -1)
	
	if altitude % 100 > 90 then
    	running_txt_move_carot(running_text_inner_alt_major100_id, ( altitude - 90 - (math.floor(altitude / 100) * 90) ) * -0.1 )
    else
    	running_txt_move_carot(running_text_inner_alt_major100_id, math.floor(altitude / 100) * -1)
    end
	
	if (altitude % 1000) > 990 then
    	running_txt_move_carot(running_text_inner_alt_major1000_id, (( altitude - 990 - (math.floor(altitude / 1000) * 990) ) * -0.1))
    else
    	running_txt_move_carot(running_text_inner_alt_major1000_id, math.floor( altitude / 1000 ) * -1)
    end 

	running_txt_move_carot(running_text_alt, (altitude / 200) * -1)
    running_img_move_carot(running_img_alt, (altitude / 200) * -1)

	yalt = 327 + (altitude * 0.8)
	yalt = var_cap(yalt, 327, 600)
	
	viewport_rect(running_text_alt, 470, 0, 130, yalt)
	viewport_rect(running_img_alt, 470, 0, 130, yalt)
    
end

-- Dataref and variable subscribe --
xpl_dataref_subscribe("sim/cockpit2/gauges/indicators/heading_electric_deg_mag_copilot", "FLOAT",
                      "sim/cockpit2/gauges/indicators/roll_electric_deg_copilot", "FLOAT",
                      "sim/cockpit2/gauges/indicators/pitch_electric_deg_copilot", "FLOAT",
                      "sim/cockpit2/gauges/indicators/airspeed_kts_copilot", "FLOAT",
                      "sim/cockpit2/gauges/indicators/altitude_ft_copilot", "FLOAT",
                      new_data)

-- **** HDG **********************************************
local HDG = -1;
xpl_dataref_subscribe("sim/cockpit2/gauges/indicators/heading_electric_deg_mag_copilot", "FLOAT", 
    function(hdg) 
        img_rotate(img_compass, hdg * -1)
        local h = var_round(hdg, 0)
        if h ~= HDG then 
            HDG = h
            txt_set(txt_heading, "H " .. string.format("%03d", h))
        end 
    end)

-- **** BARO **********************************************
xpl_dataref_subscribe("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_copilot", "FLOAT", 
                      "cl300/baro_pref", "INT", 
    function(press, pref) 
        if var_round(press, 2) == 29.92 then
            txt_set(txt_pressure, "STD")
        else
            if pref == 0 then
                txt_set(txt_pressure, var_round(press, 2) )
            else
                local p = var_round(press * 33.86389, 1)
                txt_set(txt_pressure, string.format("%d.%d", math.floor(p), 10 * (p - math.floor(p))))
            end
        end
    end)



-- ************************************************************************
-- ** STBY INSTRUMENT
-- ************************************************************************-- Blank STBY INSTR if there's no bus power
local iBLK = img_add_fullscreen("!BLACK.png")
local iDIM = img_add_fullscreen("!BLACK_40.png")

-- black displays if there's no bus power:
xpl_dataref_subscribe("sim/cockpit2/electrical/bus_volts", "FLOAT[6]", function(v) visible(iBLK, v[3] < 10) end)

-- dim displays
xpl_dataref_subscribe("cl300/stby_ins_dim_brt", "INT", function(v) visible(iDIM, v == 0) end)