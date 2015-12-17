txt_load_font("VeraBd.ttf")
txt_load_font("NewSeg7Italic.ttf")
local BG    = img_add_fullscreen("black.png")

local SL  = "-fx-font-family:\"NewSeg7\";  -fx-font-size:68px; -fx-fill: #cccccc; -fx-font-weight:regular; -fx-text-alignment:center;"
local SS  = "-fx-font-family:\"NewSeg7\";  -fx-font-size:40px; -fx-fill: #cccccc; -fx-font-weight:regular; -fx-text-alignment:center;"
local VL  = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:20px; -fx-fill: #cccccc; -fx-font-weight:bold; -fx-text-alignment:center;"
local VS  = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:16px; -fx-fill: #cccccc; -fx-font-weight:bold; -fx-text-alignment:center;"
local VSl = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:16px; -fx-fill: #cccccc; -fx-font-weight:bold; -fx-text-alignment:left;"
local VSr = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:16px; -fx-fill: #cccccc; -fx-font-weight:bold; -fx-text-alignment:right;"

local tl_FLT_ET  = txt_add("ET",   VL,    4,  12, 50, 25)
local tn_FLT_HH  = txt_add("88",   SL,   56,   4, 86, 80)
local tn_FLT_CO  = txt_add(":",    SL,  142,   4,  8, 80)
local tn_FLT_MM  = txt_add("88",   SL,  150,   4, 86, 80)
local tl_FLT_HH  = txt_add("HH",   VS,   56,  82, 86, 25)
local tl_FLT_MM  = txt_add("MM",   VS,  150,  82, 86, 25)

local tl_CLK_UTC = txt_add("UTC",  VL,    4, 108, 50, 25)
local tl_CLK_GPS = txt_add("GPS",  VL,    4, 132, 50, 25)
local tn_CLK_HH  = txt_add("88",   SL,   56, 100, 86, 80)
local tn_CLK_CO  = txt_add(":",    SL,  142, 100,  8, 80)
local tn_CLK_MM  = txt_add("88",   SL,  150, 100, 86, 80)
local tn_CLK_CO2 = txt_add(":",    SS,  238, 104,  4, 50)
local tn_CLK_SS  = txt_add("88",   SS,  242, 104, 54, 50)
local tl_CLK_HH  = txt_add("HH",   VSl,  56, 178, 86, 25)
local tl_CLK_DAY = txt_add("DAY",  VSr,  56, 178, 86, 25)
local tl_CLK_MM  = txt_add("MM",   VSl, 150, 178, 86, 25)
local tl_CLK_MON = txt_add("MON",  VSr, 150, 178, 86, 25)
local tl_CLK_SS  = txt_add("SS",   VS,  232, 178, 48, 25)

local tl_CHR_CHR = txt_add("CHR",  VL,    4, 204, 50, 25)
local tn_CHR_MM  = txt_add("88",   SL,   56, 196, 86, 80)
local tn_CHR_CO  = txt_add(":",    SL,  142, 196,  8, 80)
local tn_CHR_SS  = txt_add("88",   SL,  150, 196, 86, 80)
local tl_CHR_MM  = txt_add("MM",   VS,   56, 274, 86, 25)
local tl_CHR_SS  = txt_add("SS",   VS,  150, 274, 86, 25)

-- ********** TIMER *****************************************
local gp_CHR = group_add(tl_CHR_CHR, tn_CHR_MM, tn_CHR_CO, tn_CHR_SS, tl_CHR_MM, tl_CHR_SS)
visible(gp_CHR, false)

local CHR_RUNNING = 0
function chr_timer() if CHR_RUNNING == 0 then visible(gp_CHR, false) end end
-- show/hide chrono
xpl_dataref_subscribe("sim/cockpit2/clock_timer/timer_running", "INT", 
    function(v) 
        CHR_RUNNING = v 
        if v == 0 then timer_start(10000,nil,chr_timer) 
        else           visible(gp_CHR, true)
        end 
    end)

xpl_dataref_subscribe("sim/cockpit2/clock_timer/elapsed_time_minutes", "INT", function(v) txt_set(tn_CHR_MM, string.format("%02d", v)) end)
xpl_dataref_subscribe("sim/cockpit2/clock_timer/elapsed_time_seconds", "INT", function(v) txt_set(tn_CHR_SS, string.format("%02d", v)) end)

-- ********** CLOCK *****************************************
local gp_CLK  = group_add(tn_CLK_CO, tl_CLK_HH, tl_CLK_MM, tl_CLK_SS, tn_CLK_CO2, tn_CLK_SS)
local gp_DATE = group_add(tl_CLK_DAY, tl_CLK_MON)
xpl_dataref_subscribe("cl300/clock_mode", "INT", 
                      "sim/cockpit2/clock_timer/local_time_hours", "INT",
                      "sim/cockpit2/clock_timer/zulu_time_hours",  "INT",
                      "sim/cockpit2/clock_timer/current_day", "INT",
    function(m, l, z, d) 
        if     m == 0 then txt_set(tn_CLK_HH, string.format("%02d", l))
        elseif m == 1 then txt_set(tn_CLK_HH, string.format("%02d", z))
        elseif m == 2 then txt_set(tn_CLK_HH, string.format("%02d", d))
        end
        visible(gp_CLK,  m < 2)
        visible(gp_DATE, m == 2)
        visible(tl_CLK_UTC, m == 1)
    end)
xpl_dataref_subscribe("cl300/clock_mode", "INT", 
                      "sim/cockpit2/clock_timer/local_time_minutes", "INT",
                      "sim/cockpit2/clock_timer/zulu_time_minutes",  "INT",
                      "sim/cockpit2/clock_timer/current_month", "INT",
    function(m, l, z, d) 
        if     m == 0 then txt_set(tn_CLK_MM, string.format("%02d", l))
        elseif m == 1 then txt_set(tn_CLK_MM, string.format("%02d", z))
        elseif m == 2 then txt_set(tn_CLK_MM, string.format("%02d", d))
        end
    end)
xpl_dataref_subscribe("cl300/clock_mode", "INT", 
                      "sim/cockpit2/clock_timer/local_time_seconds", "INT",
                      "sim/cockpit2/clock_timer/zulu_time_seconds",  "INT",
    function(m, l, z) 
        if     m == 0 then txt_set(tn_CLK_SS, string.format("%02d", l))
        elseif m == 1 then txt_set(tn_CLK_SS, string.format("%02d", z))
        end
    end)
xpl_dataref_subscribe("cl300/clock_gps", "INT", function(v) visible(tl_CLK_GPS, v == 1) end)


-- ********** CLOCK *****************************************
xpl_dataref_subscribe("cl300/clock_flt_time_s", "INT", 
    function(s) 
        txt_set(tn_FLT_HH, string.format("%02d", math.floor(s/3600) % 100)) -- Cut to last two digits
        txt_set(tn_FLT_MM, string.format("%02d", math.floor(s/60) % 60))
    end)
    
-- ********** POWER *****************************************
-- black displays if there's no bus power:
local BLANK = img_add_fullscreen("black.png")
xpl_dataref_subscribe("sim/cockpit2/electrical/bus_volts", "FLOAT[6]", function(v) visible(BLANK, v[1] < 10 and v[2] < 10) end)
