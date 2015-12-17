PAGE = Page.new("cl300/mfd_ecs_" .. SIDE, "ECS.png", 0, 412, 670, 392)

local iecsENG_B_L1_L    = Image.new("green_line.png",         92, 706, 101,  4, tGROUPED)
local iecsENG_B_L2_L    = Image.new("green_line.png",        219, 706,  43,  4, tGROUPED)
local iecsENG_B_L3_L    = Image.new("green_line.png",        258, 691,   4, 19, tGROUPED)
local iecsENG_B_VV_L    = Image.new("antice_page3.png",      117, 697,  23, 23, tGROUPED)
local gecsENG_B_L       = Group.new({iecsENG_B_L1_L,iecsENG_B_L2_L,iecsENG_B_L3_L,iecsENG_B_VV_L}, tOPTIONAL)

local iecsENG_B_L1_R    = Image.new("green_line.png",        476, 706,  98,  4, tGROUPED)
local iecsENG_B_L2_R    = Image.new("green_line.png",        406, 706,  43,  4, tGROUPED)
local iecsENG_B_L3_R    = Image.new("green_line.png",        406, 691,   4, 19, tGROUPED)
local iecsENG_B_VV_R    = Image.new("antice_page3.png",      522, 697,  23, 23, tGROUPED)
local gecsENG_B_R       = Group.new({iecsENG_B_L1_R,iecsENG_B_L2_R,iecsENG_B_L3_R,iecsENG_B_VV_R}, tOPTIONAL)

local iecsAPU_B_L1      = Image.new("green_line.png",        370, 706,   4, 61, tGROUPED) 
local iecsAPU_B_L2      = Image.new("green_line.png",        406, 691,   4, 19, tGROUPED) 
local iecsAPU_B_L3      = Image.new("green_line.png",        370, 706,  37,  4, tGROUPED) 
local iecsAPU_B_VV      = Image.new("antice_page6.png",      361, 725,  23, 23, tGROUPED) 
local gecsAPU_B         = Group.new({iecsAPU_B_L1,iecsAPU_B_L2,iecsAPU_B_L3,iecsAPU_B_VV}, tOPTIONAL)

local iecsXBLD_L1       = Image.new("green_line.png",        258, 706, 151,  4, tGROUPED) 
local iecsXBLD_VV       = Image.new("antice_page3.png",      320, 697,  23, 23, tGROUPED) 
local gecsXBLD          = Group.new({iecsXBLD_L1,iecsXBLD_VV}, tOPTIONAL)

local iecsRAMA_L1       = Image.new("green_line.png",        112, 553, 118,  4, tGROUPED) 
local iecsRAMA_L2       = Image.new("green_line.png",        112, 533,   4, 20, tGROUPED) 
local iecsRAMA_VV       = Image.new("antice_page3.png",      140, 544,  23, 23, tGROUPED) 
local gecsRAMA          = Group.new({iecsRAMA_L1,iecsRAMA_L2,iecsRAMA_VV}, tOPTIONAL)

local iecsCAB_FD_L1     = Image.new("green_line.png",        224, 553, 214,  4, tGROUPED) 
local iecsCAB_FD_L2     = Image.new("green_line.png",        225, 533,   4, 20, tGROUPED) 
local iecsCAB_FD_L3     = Image.new("green_line.png",        225, 479,   4, 33, tGROUPED) 
local iecsCAB_FD_L4     = Image.new("green_line.png",        435, 533,   4, 20, tGROUPED) 
local iecsCAB_FD_L5     = Image.new("green_line.png",        435, 479,   4, 33, tGROUPED) 
local gecsCAB_FD        = Group.new({iecsCAB_FD_L1,iecsCAB_FD_L2,iecsCAB_FD_L3,iecsCAB_FD_L4,iecsCAB_FD_L5}, tOPTIONAL)

local iecsPACK_L1       = Image.new("green_line.png",        258, 626,   4, 81, tGROUPED) 
local iecsPACK_L2       = Image.new("green_line.png",        258, 557,   4, 17, tGROUPED) 
local iecsPACK_VV       = Image.new("antice_page6.png",      249, 669,  23, 23, tGROUPED) 
local iecsPACK_BX       = Image.new("antice_page7.png",      201, 572, 118, 55, tGROUPED) 
local gecsPACK          = Group.new({iecsPACK_L1,iecsPACK_L2,iecsPACK_VV,iecsPACK_BX}, tOPTIONAL)

local iecsTRIM_L1       = Image.new("green_line.png",        406, 626,   4, 81, tGROUPED) 
local iecsTRIM_L2       = Image.new("green_line.png",        406, 557,   4, 17, tGROUPED) 
local iecsTRIM_VV       = Image.new("antice_page6.png",      396, 669,  23, 23, tGROUPED) 
local iecsTRIM_BX       = Image.new("antice_page7.png",      346, 572, 118, 55, tGROUPED) 
local gecsTRIM          = Group.new({iecsTRIM_L1,iecsTRIM_L2,iecsTRIM_VV,iecsTRIM_BX}, tOPTIONAL)

local iecsBOTH_L1       = Image.new("green_line.png",        259, 649, 150,  4, tGROUPED) 
local iecsBOTH_VV       = Image.new("antice_page3.png",      321, 639,  23, 23, tGROUPED) 
local gecsBOTH          = Group.new({iecsBOTH_L1,iecsBOTH_VV}, tOPTIONAL)


local iecsCAB_U         = Image.new("cabrate2_up.png",                 615, 458, 10, 14, tOPTIONAL)
local iecsCAB_D         = Image.new("cabrate2_dn.png",                 615, 459, 10, 14, tOPTIONAL)
local tecsCAB_OXY       = Text.new("1200",  TXT_12B_R, {"#00FF00"},    570, 427, 40, 12, tCONST)
local tecsCAB_ALT       = Text.new("3600",  TXT_12B_R, {"#00FF00"},    570, 443, 40, 12, tCONST)
local tecsCAB_VVI       = Text.new("-1200", TXT_12B_R, {"#00FF00"},    570, 459, 40, 12, tCONST)
local tecsCAB_DIFFP     = Text.new("9.5",   TXT_12B_R, {"#00FF00"},    570, 475, 40, 12, tCONST)
local tecsCAB_LDG       = Text.new("1000",  TXT_12B_R, {"#00FFFF"},    570, 491, 40, 12, tCONST)
local tecsMANUAL        = Text.new("MANUAL",TXT_12B_L, {"#CCCCCC"},    305, 497, 60, 12, tOPTIONAL)
local tecsPSI_L         = Text.new("52",    TXT_12B_R, {"#CCCCCC"},    194, 697, 20, 12, tOPTIONAL)
local tecsPSI_R         = Text.new("52",    TXT_12B_R, {"#CCCCCC"},    450, 697, 20, 12, tOPTIONAL)
local tecsTEMP_FD_DIAL  = Text.new("30°",    TXT_12B_R, {"#00FFFF"},    224, 488, 34, 12, tOPTIONAL)
local tecsTEMP_FD_TEMP  = Text.new("30°",    TXT_12B_R, {"#CCCCCC"},    197, 464, 34, 12, tOPTIONAL)
local tecsTEMP_FD_DUCT  = Text.new("30°",    TXT_12B_R, {"#CCCCCC"},    197, 516, 34, 12, tOPTIONAL)
local tecsTEMP_CAB_DIAL = Text.new("30°",    TXT_12B_R, {"#00FFFF"},    432, 488, 34, 12, tOPTIONAL)
local tecsTEMP_CAB_TEMP = Text.new("30°",    TXT_12B_R, {"#CCCCCC"},    407, 463, 34, 12, tOPTIONAL)
local tecsTEMP_CAB_DUCT = Text.new("30°",    TXT_12B_R, {"#CCCCCC"},    407, 516, 34, 12, tOPTIONAL)

xpl_dataref_subscribe("cl300/bleed_en_l_h",   "INT", 
                      "cl300/bleed_en_r_h",   "INT", 
                      "cl300/bleed_apu_h",    "INT", 
                      "cl300/bleed_xbleed_h", "INT", 
    function(bl, br, ba, bx) 
        gecsENG_B_L:showElem(bl > 0) 
        gecsENG_B_R:showElem(br > 0) 
        gecsAPU_B:showElem(ba > 0) 
        gecsXBLD:showElem((bl+br+ba)>0 and bx > 0) 
    end)
xpl_dataref_subscribe("cl300/aircond_ramair_h", "INT", function(v)  end)

xpl_dataref_subscribe("cl300/aircond_has_pack", "INT", 
                      "cl300/aircond_has_trim", "INT",
                      "cl300/aircond_ramair_h", "INT",
    function(p, t, r)
        gecsPACK:showElem(p > 0) 
        gecsTRIM:showElem(t > 0) 
        gecsBOTH:showElem(p > 0 and t > 0) 
        gecsRAMA:showElem(r > 0)
        gecsCAB_FD:showElem(p+t+r > 0)
    end)
     
xpl_dataref_subscribe("sim/cockpit2/pressurization/indicators/cabin_altitude_ft",       "FLOAT", function(v) tecsCAB_ALT:text(limit(v,0)) end)
xpl_dataref_subscribe("sim/cockpit2/pressurization/indicators/cabin_vvi_fpm",           "FLOAT", function(v) tecsCAB_VVI:text(limit(v,0)) iecsCAB_U:showElem(z~=0 and v>10) iecsCAB_D:showElem(z~=0 and v<-10) end)
xpl_dataref_subscribe("sim/cockpit2/pressurization/indicators/pressure_diffential_psi", "FLOAT", function(v) tecsCAB_DIFFP:text(limit(v,1)) end)
xpl_dataref_subscribe("cl300/pressure_lndg_alt_2",                                      "FLOAT", function(v) tecsCAB_LDG:text(25*limit((v+1)*200,0)) end)
xpl_dataref_subscribe("cl300/bleed_psi_l",                                              "FLOAT", function(v) tecsPSI_L:text(limit(v,0)) end)
xpl_dataref_subscribe("cl300/bleed_psi_r",                                              "FLOAT", function(v) tecsPSI_R:text(limit(v,0)) end)
xpl_dataref_subscribe("cl300/aircond_man_temp_h",                                       "INT", function(v) tecsMANUAL:text(v > 0 and "MANUAL" or "") end)

xpl_dataref_subscribe("cl300/aircond_tempr_cock_ddial",                                 "FLOAT", function(v) tecsTEMP_FD_DIAL:text(limit(v,0)) end)
xpl_dataref_subscribe("cl300/aircond_tempr_cock_duct",                                  "FLOAT", function(v) tecsTEMP_FD_DUCT:text(limit(v,0)) end)
xpl_dataref_subscribe("cl300/aircond_tempr_cock_c",                                     "FLOAT", function(v) tecsTEMP_FD_TEMP:text(limit(v,0)) end)
xpl_dataref_subscribe("cl300/aircond_tempr_cab_ddial",                                  "FLOAT", function(v) tecsTEMP_CAB_DIAL:text(limit(v,0)) end)
xpl_dataref_subscribe("cl300/aircond_tempr_cab_duct",                                   "FLOAT", function(v) tecsTEMP_CAB_DUCT:text(limit(v,0)) end)
xpl_dataref_subscribe("cl300/aircond_tempr_cab_c",                                      "FLOAT", function(v) tecsTEMP_CAB_TEMP:text(limit(v,0)) end)

PAGE:finalize()

