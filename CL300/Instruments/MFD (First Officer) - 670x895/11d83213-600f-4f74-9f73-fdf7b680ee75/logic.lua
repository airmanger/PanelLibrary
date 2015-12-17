-- NOTE: The main logic is distributed into individual library files for the different display components!

-- ***** MFD CONTROL **********************************************
local itopMC_BLK   = img_add("black.png",            0, 768, 72, 36)
local itopMC_A_L   = img_add("mfd_ctrl_l.png",      10, 785, 52, 19)
local itopMC_A_R   = img_add("mfd_ctrl_r.png",      10, 785, 52, 19)
local ttopMC_TXT   = txt_add("MFD\nCONTROL", TXT_12B_L .. "#FFFFFF",   5, 758, 65, 28) 
xpl_dataref_subscribe("cl300/mfdpan_lr_sw", "INT", function(v) visible(itopMC_A_L, v == 0) visible(itopMC_A_R, v == 1) end)


-- ***** BRIGHTNESS **********************************************
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
