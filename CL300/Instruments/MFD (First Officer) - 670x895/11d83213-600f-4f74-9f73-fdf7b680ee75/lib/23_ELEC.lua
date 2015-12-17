PAGE = Page.new("cl300/mfd_electr_" .. SIDE, "ELEC.png", 0, 412, 670, 392)




local ielecBUS_L    = Image.new("elec_page3.png",         61, 561, 185, 64, tOPTIONAL)
local ielecBUS_R    = Image.new("elec_page4.png",        422, 561, 188, 64, tOPTIONAL)

local ielecBAT_BX_L = Image.new("elec_page1.png",        176, 461,  60, 48, tGROUPED)
local ielecBAT_W1_L = Image.new("green_line.png",        204, 506,   3, 56, tGROUPED)
local gelecBAT_L    = Group.new({ielecBAT_BX_L,ielecBAT_W1_L}, tOPTIONAL)

local ielecBAT_BX_R = Image.new("elec_page1.png",        439, 461,  60, 48, tGROUPED)
local ielecBAT_W1_R = Image.new("green_line.png",        466, 506,   3, 56, tGROUPED)
local gelecBAT_R    = Group.new({ielecBAT_BX_R,ielecBAT_W1_R}, tOPTIONAL)

local ielecGEN_BX_L = Image.new("elec_page2.png",        185, 715,  42, 40, tGROUPED)
local ielecGEN_W1_L = Image.new("green_line.png",        204, 666,   3, 51, tGROUPED)
local ielecGEN_W2_L = Image.new("green_line.png",        204, 623,   3, 21, tGROUPED)
local gelecGEN_L    = Group.new({ielecGEN_BX_L,ielecGEN_W1_L,ielecGEN_W2_L}, tOPTIONAL)

local ielecGEN_BX_R = Image.new("elec_page2.png",        447, 715,  42, 40, tGROUPED)
local ielecGEN_W1_R = Image.new("green_line.png",        466, 666,   3, 51, tGROUPED)
local ielecGEN_W2_R = Image.new("green_line.png",        466, 623,   3, 21, tGROUPED)
local gelecGEN_R    = Group.new({ielecGEN_BX_R,ielecGEN_W1_R,ielecGEN_W2_R}, tOPTIONAL)

local ielecAPU_BX   = Image.new("elec_page2.png",        313, 715,  42, 40, tGROUPED)
local ielecAPU_W1   = Image.new("green_line.png",        333, 666,  3,  51, tGROUPED)
local gelecAPU      = Group.new({ielecAPU_BX,ielecAPU_W1}, tOPTIONAL)

local ielecAPU_W2_L = Image.new("green_line.png",        244, 611,  74,  4, tGROUPED)
local ielecAPU_W3_L = Image.new("green_line.png",        315, 612,   4, 32, tGROUPED)
local gelecAPU_L    = Group.new({ielecAPU_W2_L,ielecAPU_W3_L}, tOPTIONAL)

local ielecAPU_W2_R = Image.new("green_line.png",        351, 611,  76,  4, tGROUPED)
local ielecAPU_W3_R = Image.new("green_line.png",        350, 612,   4, 32, tGROUPED)
local gelecAPU_R    = Group.new({ielecAPU_W2_R,ielecAPU_W3_R}, tOPTIONAL)

local ielecBUS_TIE  = Image.new("green_line.png",        243, 571, 181,  4, tOPTIONAL)

local ielecGPU_BX   = Image.new("elec_page2.png",        315, 484,  42, 40, tGROUPED)
local ielecGPU_W1   = Image.new("green_line.png",        333, 521,   4, 51, tGROUPED)
local gelecGPU      = Group.new({ielecGPU_BX,ielecGPU_W1}, tOPTIONAL)

local telecGEN_A_L   = Text.new("96",   TXT_12B_R , {"#00FF00", "#CCCCCC"}, 181, 649, 32, 12, tCONST)
local telecGEN_A_A   = Text.new("96",   TXT_12B_R , {"#00FF00", "#CCCCCC"}, 311, 649, 32, 12, tCONST)
local telecGEN_A_R   = Text.new("96",   TXT_12B_R , {"#00FF00", "#CCCCCC"}, 445, 649, 32, 12, tCONST)
local telecGEN_V_L   = Text.new("28.0", TXT_12B_R , {"#00FF00", "#CCCCCC"}, 187, 758, 32, 12, tCONST)
local telecGEN_V_A   = Text.new("28.0", TXT_12B_R , {"#00FF00", "#CCCCCC"}, 314, 758, 32, 12, tCONST)
local telecGEN_V_R   = Text.new("28.0", TXT_12B_R , {"#00FF00", "#CCCCCC"}, 446, 759, 32, 12, tCONST)
local telecBAT_V_L   = Text.new("28.0", TXT_12B_R , {"#00FF00", "#CCCCCC"}, 182, 489, 32, 12, tCONST)
local telecBAT_V_R   = Text.new("28.0", TXT_12B_R , {"#00FF00", "#CCCCCC"}, 444, 489, 32, 12, tCONST)
local telecBAT_T_L   = Text.new("26",   TXT_12B_R , {"#00FF00", "#CCCCCC"}, 173, 448, 32, 12, tCONST)
local telecBAT_T_R   = Text.new("23",   TXT_12B_R , {"#00FF00", "#CCCCCC"}, 436, 448, 32, 12, tCONST)
local telecGPU_V     = Text.new("28.0", TXT_12B_R , {"#00FF00", "#CCCCCC"}, 310, 466, 32, 12, tCONST)

-- BUS
xpl_dataref_subscribe("sim/cockpit2/electrical/bus_volts", "FLOAT[6]", "cl300/electr_apugen_r", "INT", 
    function(v,ar) 
        ielecBUS_L:showElem(v[1] > 10) 
        ielecBUS_R:showElem(v[2] > 10 or ar > 0) 
    end)
-- GEN
xpl_dataref_subscribe("sim/cockpit2/electrical/generator_on", "INT[8]", 
	function(v) 
        gelecGEN_L:showElem(v[1] > 0) 
        gelecGEN_R:showElem(v[2] > 0) 
		telecGEN_A_L:colorindex(v[1] > 0 and 1 or 2)
		telecGEN_V_L:colorindex(v[1] > 0 and 1 or 2) 
		telecGEN_A_R:colorindex(v[2] > 0 and 1 or 2) 
		telecGEN_V_R:colorindex(v[2] > 0 and 1 or 2) 
	end)
xpl_dataref_subscribe("cl300/gen_amps_l",    "FLOAT", function(v) telecGEN_A_L:text(limit(v, 0)) end)
xpl_dataref_subscribe("cl300/gen_amps_r",    "FLOAT", function(v) telecGEN_A_R:text(limit(v, 0)) end)
xpl_dataref_subscribe("cl300/gen_volts_l",   "FLOAT", function(v) telecGEN_V_L:text(limit(v, 1)) end)
xpl_dataref_subscribe("cl300/gen_volts_r",   "FLOAT", function(v) telecGEN_V_R:text(limit(v, 1)) end)
-- APU
xpl_dataref_subscribe("sim/cockpit2/electrical/APU_generator_on", "INT", 
                      "cl300/electr_apugen_l",                    "INT", 
                      "cl300/electr_apugen_r",                    "INT", 
	function(v,l,r) 
        gelecAPU:showElem(v > 0) 
        gelecAPU_L:showElem(l > 0)
        gelecAPU_R:showElem(r > 0)
		telecGEN_A_A:colorindex(v > 0 and 1 or 2) 
		telecGEN_V_A:colorindex(v > 0 and 1 or 2) 
	end)
xpl_dataref_subscribe("cl300/gen_amps_apu",  "FLOAT", function(v) telecGEN_A_A:text(limit(v, 0)) end)
xpl_dataref_subscribe("cl300/gen_volts_apu", "FLOAT", function(v) telecGEN_V_A:text(limit(v, 1)) end)
-- BAT
xpl_dataref_subscribe("sim/cockpit2/electrical/battery_voltage_indicated_volts",	"FLOAT[8]",
	function(v) 
		telecBAT_V_L:text(limit(v[1], 1))
		telecBAT_V_R:text(limit(v[2], 1))
	end)
xpl_dataref_subscribe("sim/cockpit2/electrical/battery_on", 						"INT[8]", 
	function(v) 
        gelecBAT_L:showElem(v[1] > 0) 
        gelecBAT_R:showElem(v[2] > 0) 
		telecBAT_V_L:colorindex(v[1] > 0 and 1 or 2)
		telecBAT_T_L:colorindex(v[1] > 0 and 1 or 2)
		telecBAT_V_R:colorindex(v[2] > 0 and 1 or 2)
		telecBAT_T_R:colorindex(v[2] > 0 and 1 or 2)
	end)
-- GPU
xpl_dataref_subscribe("sim/cockpit/electrical/gpu_on", "INT",   
    function(v) 
        gelecGPU:showElem(v > 0) 
        telecGPU_V:colorindex(v > 0 and 1 or 2) 
    end)
xpl_dataref_subscribe("cl300/gpu_volts", "FLOAT", function(v) telecGPU_V:text(limit(v, 1)) end)
-- TIE
xpl_dataref_subscribe("sim/cockpit2/electrical/cross_tie", "INT", function(v) ielecBUS_TIE:showElem(v > 0) end)
    

PAGE:finalize()