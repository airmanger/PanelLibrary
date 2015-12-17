PAGE = Page.new("cl300/mfd_flt_ctr_" .. SIDE, "FLT.png", 0, 412, 670, 392)

-- control surfaces
local ifltRUD_G     = Image.new("fltc_rudder_grn.png",    327, 671,  7, 67, tOPTIONAL)
local ifltRUD_Y     = Image.new("fltc_rudder_yel.png",    327, 671,  7, 67, tOPTIONAL)
local ifltELV_L_G   = Image.new("fltc_trngl_l_grn.png",   215, 708, 15, 12, tOPTIONAL)
local ifltELV_L_Y   = Image.new("fltc_trngl_l_yel.png",   215, 708, 15, 12, tOPTIONAL)
local ifltELV_R_G   = Image.new("fltc_trngl_r_grn.png",   441, 708, 15, 12, tOPTIONAL)
local ifltELV_R_Y   = Image.new("fltc_trngl_r_yel.png",   441, 708, 15, 12, tOPTIONAL)
local ifltAIL_L     = Image.new("fltc_trngl_l_grn.png",    73, 609, 15, 12, tCONST)
local ifltAIL_R     = Image.new("fltc_trngl_r_grn.png",   582, 609, 15, 12, tCONST)
local ifltFLAPS_L   = Image.new("fltc_flap_l.png",        246, 562, 62, 43, tOPTIONAL)
local ifltFLAPS_R   = Image.new("fltc_flap_r.png",        363, 562, 61, 43, tOPTIONAL)
local tfltFLAPS_L   = Text.new("0", TXT_16B_C, {"#00FF00","#FFFF00"}, 267, 573, 24, 16, tCONST)
local tfltFLAPS_R   = Text.new("0", TXT_16B_C, {"#00FF00","#FFFF00"}, 381, 573, 24, 16, tCONST)

-- speedbrake/spoiler symbols
local ifltSPLR_L_Y   = Image.new("sbrake1_yellow.png", 232, 546, 21, 9, tGROUPED)
local ifltSPLR_L_G   = Image.new("sbrake1_green.png",  232, 546, 21, 9, tGROUPED)
local ifltSBRK_L_Y   = Image.new("sbrake1_yellow.png", 263, 546, 21, 9, tGROUPED)
local ifltSBRK_L_G   = Image.new("sbrake1_green.png",  263, 546, 21, 9, tGROUPED)
local ifltSBRK_R_Y   = Image.new("sbrake1_yellow.png", 387, 546, 21, 9, tGROUPED)
local ifltSBRK_R_G   = Image.new("sbrake1_green.png",  387, 546, 21, 9, tGROUPED)
local ifltSPLR_R_Y   = Image.new("sbrake1_yellow.png", 418, 546, 21, 9, tGROUPED)
local ifltSPLR_R_G   = Image.new("sbrake1_green.png",  418, 546, 21, 9, tGROUPED)

local gfltCTRL_G     = Group.new({ifltRUD_G, ifltELV_L_G, ifltELV_R_G, ifltFLAPS_L, ifltFLAPS_R, ifltSPLR_L_G, ifltSBRK_L_G, ifltSBRK_R_G, ifltSPLR_R_G}, tOPTIONAL)
local gfltCTRL_Y     = Group.new({ifltRUD_Y, ifltELV_L_Y, ifltELV_R_Y,                           ifltSPLR_L_Y, ifltSBRK_L_Y, ifltSBRK_R_Y, ifltSPLR_R_Y}, tOPTIONAL)

xpl_dataref_subscribe("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1", "FLOAT", 
    function(v) 
        gfltCTRL_Y:showElem(v < 10) 
        gfltCTRL_G:showElem(v >= 10) 
        tfltFLAPS_L:colorindex(v < 10 and 2 or 1) 
        tfltFLAPS_R:colorindex(v < 10 and 2 or 1)
    end)

xpl_dataref_subscribe("sim/flightmodel/controls/ldruddef", "FLOAT", 
    function(v) 
        ifltRUD_G:rotate(limit(v * -2.1, 0))
        ifltRUD_Y:rotate(limit(v * -2.1, 0))
    end)

xpl_dataref_subscribe("sim/flightmodel2/wing/aileron1_deg", "FLOAT[32]", 
    function(v)
        ifltAIL_L:moverel(0, limit(v[1] * 1.43, 0))
        ifltAIL_R:moverel(0, limit(v[2] * 1.43, 0))
    end)

xpl_dataref_subscribe("sim/flightmodel/controls/hstab1_elv1def", "FLOAT", 
    function(v)
        ifltELV_L_G:moverel(0, limit(v * 1.3, 0))
        ifltELV_L_Y:moverel(0, limit(v * 1.3, 0))
    end)
  
xpl_dataref_subscribe("sim/flightmodel/controls/hstab2_elv1def", "FLOAT", 
    function(v)
        ifltELV_R_G:moverel(0, limit(v * 1.3, 0))
        ifltELV_R_Y:moverel(0, limit(v * 1.3, 0))
    end)
  
-- speedbrake/spoiler lines & arrows
local ifltSPLR_LL_l  = Image.new("green_line.png",  237, 541,  2, 5, tOPTIONAL)
local ifltSPLR_LR_l  = Image.new("green_line.png",  245, 541,  2, 5, tOPTIONAL)
local ifltSBRK_LL_l  = Image.new("green_line.png",  268, 541,  2, 5, tOPTIONAL)
local ifltSBRK_LR_l  = Image.new("green_line.png",  276, 541,  2, 5, tOPTIONAL)

local ifltSBRK_RL_l  = Image.new("green_line.png",  392, 541,  2, 5, tOPTIONAL)
local ifltSBRK_RR_l  = Image.new("green_line.png",  400, 541,  2, 5, tOPTIONAL)
local ifltSPLR_RL_l  = Image.new("green_line.png",  423, 541,  2, 5, tOPTIONAL)
local ifltSPLR_RR_l  = Image.new("green_line.png",  431, 541,  2, 5, tOPTIONAL)

local ifltSPLR_LL_a  = Image.new("arrow_line2.png", 231, 545,  8, 7, tOPTIONAL)
local ifltSPLR_LR_a  = Image.new("arrow_line.png",  245, 545,  8, 7, tOPTIONAL)
local ifltSBRK_LL_a  = Image.new("arrow_line2.png", 262, 545,  8, 7, tOPTIONAL)
local ifltSBRK_LR_a  = Image.new("arrow_line.png",  276, 545,  8, 7, tOPTIONAL)

local ifltSBRK_RL_a  = Image.new("arrow_line2.png", 386, 545,  8, 7, tOPTIONAL)
local ifltSBRK_RR_a  = Image.new("arrow_line.png",  400, 545,  8, 7, tOPTIONAL)
local ifltSPLR_RL_a  = Image.new("arrow_line2.png", 417, 545,  8, 7, tOPTIONAL)
local ifltSPLR_RR_a  = Image.new("arrow_line.png",  431, 545,  8, 7, tOPTIONAL)

xpl_dataref_subscribe("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1", "FLOAT", 
                      "sim/flightmodel2/wing/spoiler1_deg",    "FLOAT[32]", 
    function(p,s1) 
        -- outer left spoiler
        if p < 5 or s1[1] < 0.91 then
            ifltSPLR_LL_l:showElem(false) 
            ifltSPLR_LL_a:showElem(false)
        else
            ifltSPLR_LL_l:showElem(true) 
            ifltSPLR_LL_a:showElem(true)
            ifltSPLR_LL_l:resize( 0, 5-s1[1]*1.2, 2, s1[1]*1.2)
            ifltSPLR_LL_a:moverel(0,  -s1[1]*1.2)
        end
        -- outer right spoiler
        if p < 5 or s1[2] < 0.91 then
            ifltSPLR_RR_l:showElem(false) 
            ifltSPLR_RR_a:showElem(false)
        else
            ifltSPLR_RR_l:showElem(true) 
            ifltSPLR_RR_a:showElem(true)
            ifltSPLR_RR_l:resize( 0, 5-s1[2]*1.2, 2, s1[2]*1.2)
            ifltSPLR_RR_a:moverel(0,  -s1[2]*1.2)
        end
    end)

xpl_dataref_subscribe("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1", "FLOAT", 
                      "sim/flightmodel2/wing/spoiler2_deg",    "FLOAT[32]", 
    function(p,s2) 
        -- inner left spoiler
        if p < 5 or s2[1] < 0.91 then
            ifltSPLR_LR_l:showElem(false) 
            ifltSPLR_LR_a:showElem(false)
        else
            ifltSPLR_LR_l:showElem(true) 
            ifltSPLR_LR_a:showElem(true)
            ifltSPLR_LR_l:resize( 0, 5-s2[1]*1.2, 2, s2[1]*1.2)
            ifltSPLR_LR_a:moverel(0,  -s2[1]*1.2)
        end
        -- inner right spoiler
        if p < 5 or s2[2] < 0.91 then
            ifltSPLR_RL_l:showElem(false) 
            ifltSPLR_RL_a:showElem(false)
        else
            ifltSPLR_RL_l:showElem(true) 
            ifltSPLR_RL_a:showElem(true)
            ifltSPLR_RL_l:resize( 0, 5-s2[2]*1.2, 2, s2[2]*1.2)
            ifltSPLR_RL_a:moverel(0,  -s2[2]*1.2)
        end
    end)

xpl_dataref_subscribe("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1", "FLOAT", 
                      "sim/flightmodel2/wing/speedbrake1_deg", "FLOAT[32]", 
    function(p,sb) 
        -- left speedbrakes
        if p < 5 or sb[1] < 1.12 then
            ifltSBRK_LL_l:showElem(false) 
            ifltSBRK_LL_a:showElem(false)
            ifltSBRK_LR_l:showElem(false) 
            ifltSBRK_LR_a:showElem(false)
        else
            ifltSBRK_LL_l:showElem(true) 
            ifltSBRK_LL_a:showElem(true)
            ifltSBRK_LR_l:showElem(true) 
            ifltSBRK_LR_a:showElem(true)
            ifltSBRK_LL_l:resize( 0, 5-sb[1]*0.9, 2, sb[1]*0.9)
            ifltSBRK_LL_a:moverel(0,  -sb[1]*0.9)
            ifltSBRK_LR_l:resize( 0, 5-sb[1]*0.9, 2, sb[1]*0.9)
            ifltSBRK_LR_a:moverel(0,  -sb[1]*0.9)
        end
        -- right speedbrakes
        if p < 5 or sb[2] < 1.12 then
            ifltSBRK_RL_l:showElem(false) 
            ifltSBRK_RL_a:showElem(false)
            ifltSBRK_RR_l:showElem(false) 
            ifltSBRK_RR_a:showElem(false)
        else
            ifltSBRK_RL_l:showElem(true) 
            ifltSBRK_RL_a:showElem(true)
            ifltSBRK_RR_l:showElem(true) 
            ifltSBRK_RR_a:showElem(true)
            ifltSBRK_RL_l:resize( 0, 5-sb[2]*0.9, 2, sb[2]*0.9)
            ifltSBRK_RL_a:moverel(0,  -sb[2]*0.9)
            ifltSBRK_RR_l:resize( 0, 5-sb[2]*0.9, 2, sb[2]*0.9)
            ifltSBRK_RR_a:moverel(0,  -sb[2]*0.9)
        end
    end)

PAGE:finalize()

