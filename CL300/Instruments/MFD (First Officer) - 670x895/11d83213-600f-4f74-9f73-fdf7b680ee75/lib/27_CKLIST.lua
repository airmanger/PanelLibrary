local OFFSET  = ((not CAPTAIN) and -403 or 0)
PAGE = Page.new("cl300/mfd_checkl_" .. SIDE, "CKLIST.png", 0, 412+OFFSET, 670, 392)

function cklL(s) 
	return s:gsub("   .*", "")
end
function cklR(s) 
	return s:gsub(".*   ", "")
end

local tcklTITLE = Text.new("", TXT_14B_C , {"#FFFFFF"}, 240, 432+OFFSET, 410, 19, tCONST)
xpl_dataref_subscribe("cl300/cklst_line_title_text",  "STRING", function(v) tcklTITLE:text(v) end)

local tcklLINES_L = {}
local tcklLINES_R = {}
for i=1,17 do
	tcklLINES_L[i] = Text.new("", TXT_14B_L , {"#00FF00"}, 240, 442+i*19+OFFSET, 410, 19, tCONST)
	tcklLINES_R[i] = Text.new("", TXT_14B_R , {"#00FF00"}, 240, 442+i*19+OFFSET, 410, 19, tCONST)
	xpl_dataref_subscribe("cl300/cklst_line_"..i.."_color", "INT",    
		function(v) 
			tcklLINES_L[i]:colorhtml(v)
			tcklLINES_R[i]:colorhtml(v)
		end)
	xpl_dataref_subscribe("cl300/cklst_line_"..i.."_text",  "STRING", 
		function(v) 
			tcklLINES_L[i]:text(convertString(cklL(v)))
			tcklLINES_R[i]:text(convertString(cklR(v)))
		end)
end

PAGE:finalize()