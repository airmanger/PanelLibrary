if CAPTAIN then
	local icasMSG = Image.new("msgs.png", 492, 6, 50, 24, tOPTIONAL)
	xpl_dataref_subscribe("cl300/mfd_pan_cas", "INT", "cl300/has_cas", "INT", function(v,w) icasMSG:showElem(v > 0 and w > 0) end)

	local tcasLINES = {}
	for i=1,25 do
		tcasLINES[i] = Text.new("", TXT_12B_L, {"#CCCCCC"}, 490, 3+i*15, 180, 15, tGROUPED)
		xpl_dataref_subscribe("cl300/cas_line_"..i.."_color", "INT",    function(v) tcasLINES[i]:colorhtml(v) end)
		xpl_dataref_subscribe("cl300/cas_line_"..i.."_text",  "STRING", function(v) tcasLINES[i]:text(v) end)
	end
	
	local gcasLINES = Group.new(tcasLINES, tOPTIONAL)
	xpl_dataref_subscribe("cl300/mfd_pan_cas", "INT", function(v) gcasLINES:showElem(v == 0) end)
end
