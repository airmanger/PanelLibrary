txt_load_font("Vera.ttf")
txt_load_font("VeraBd.ttf")

TXT_20B_L = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:20px; -fx-font-weight:bold; -fx-text-alignment:left;   -fx-fill: "
TXT_20B_C = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:20px; -fx-font-weight:bold; -fx-text-alignment:center; -fx-fill: "
TXT_20B_R = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:20px; -fx-font-weight:bold; -fx-text-alignment:right;  -fx-fill: "

TXT_18B_L = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:18px; -fx-font-weight:bold; -fx-text-alignment:left;   -fx-fill: "
TXT_18B_C = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:18px; -fx-font-weight:bold; -fx-text-alignment:center; -fx-fill: "
TXT_18B_R = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:18px; -fx-font-weight:bold; -fx-text-alignment:right;  -fx-fill: "

TXT_16B_L = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:16px; -fx-font-weight:bold; -fx-text-alignment:left;   -fx-fill: "
TXT_16B_C = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:16px; -fx-font-weight:bold; -fx-text-alignment:center; -fx-fill: "
TXT_16B_R = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:16px; -fx-font-weight:bold; -fx-text-alignment:right;  -fx-fill: "

TXT_14B_L = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:14px; -fx-font-weight:bold; -fx-text-alignment:left;   -fx-fill: "
TXT_14B_C = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:14px; -fx-font-weight:bold; -fx-text-alignment:center; -fx-fill: "
TXT_14B_R = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:14px; -fx-font-weight:bold; -fx-text-alignment:right;  -fx-fill: "

TXT_12B_L = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:12px; -fx-font-weight:bold; -fx-text-alignment:left;   -fx-fill: "
TXT_12B_C = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:12px; -fx-font-weight:bold; -fx-text-alignment:center; -fx-fill: "
TXT_12B_R = "-fx-font-family:\"Bitstream Vera Sans\"; -fx-font-size:12px; -fx-font-weight:bold; -fx-text-alignment:right;  -fx-fill: "

HEIGHT  = 895
WIDTH   = 670
CAPTAIN = (instrument_prop("TYPE"):find("First Officer") == nil)
SIDE    = (CAPTAIN and "l" or "r")
BUS     = (CAPTAIN and 1 or 2)
BRIGHT  = "cl300/" .. (CAPTAIN and "p" or "c") .. "mfd_h"

img_add_fullscreen(CAPTAIN and "BG_ENGN.png" or "BG_BLACK.png")

tCONST    = 0
tOPTIONAL = 1
tGROUPED  = 2

PAGE = nil

-- =========================================================== 

Page = {}
Page.__index = Page
function Page.new(dataref, png, x, y, w, h)
	local self = {constant = {}, optional = {}, dataref = dataref}
	if png ~= nil then
		self.img = img_add(png, x, y, w, h)
		table.insert(self.constant,self.img)
	end
    setmetatable(self,Page)
    return self
end

function Page:addElem(e, etype)
	if etype == tCONST then
		table.insert(self.constant, e.elem)
	elseif etype == tOPTIONAL then 
		table.insert(self.optional, e)
	end
end

function Page:finalize()
	self.group = group_add(table.unpack(self.constant))
	xpl_dataref_subscribe(self.dataref, "INT", 
		function(x) 
			visible(self.group, x > 0)
			for k,v in pairs(self.optional) do
				v:showPage(x > 0)
			end
		end)
end

-- =========================================================== 


Image = {}
Image.__index = Image
function Image.new(png, x, y, w, h, opt)
    local self = {x = x, y = y, w = w, r = 0, ox = 0, oy = 0, vp = true, ve = true}
	setmetatable(self,Image)
	
	self.elem = img_add(png, x, y, w, h)
	
	if PAGE ~= nil then PAGE:addElem(self, opt) end
    return self
end

function Image:rotate(r) 
	r = math.floor(r + 0.5)
	if self.r == r then return end
	img_rotate(self.elem, r)
end

function Image:moveabs(x, y) 
	if self.x == x and self.y == y then return end
	self.x = x
	self.y = y
	move(self.elem, x, y, self.w, self.h)
end

function Image:moverel(x, y) 
	x = math.floor(x + 0.5)
	y = math.floor(y + 0.5)
	if self.ox == x and self.oy == y then return end
	self.ox = x
	self.oy = y
	move(self.elem, self.x + x, self.y + y, self.w, self.h)
end

function Image:resize(x, y, w, h) 
	x = math.floor(x + 0.5)
	y = math.floor(y + 0.5)
	w = math.floor(w + 0.5)
	h = math.floor(h + 0.5)
	if self.w == w and self.h == h and self.ox == x and self.oy == y then return end
	self.w  = w
	self.h  = h
	self.ox = x
	self.oy = y
	move(self.elem, self.x + x, self.y + y, self.w, self.h)
end

function Image:showElem(show)
	if show == self.ve then return end
	if (show and self.vp) ~= (self.vp and self.ve) then
		visible(self.elem, show and self.vp)
	end
	self.ve = show
end

function Image:showPage(show)
	if show == self.vp then return end
	if (show and ve) ~= (self.vp and self.ve) then
		visible(self.elem, show and self.ve)
	end
	self.vp = show
end

-- =========================================================== 

Text = {}
Text.__index = Text
function Text.new(default, style, colors, x, y, w, h, opt)
    local self = {style = style, colors = colors, x = x, y = y, w = w, h = h, ox = 0, oy = 0, vp = true, ve = true}
	setmetatable(self,Text)

	self.col   = self.colors[1]
	self.val   = default
	self.elem  = txt_add(default, self:getStyle(), x, y, w, h)
	
	if PAGE ~= nil then PAGE:addElem(self, opt) end
    return self
end

function Text:moverel(x, y) 
	if self.ox == x and self.oy == y then return end
	self.ox = x
	self.oy = y
	move(self.elem, self.x + x, self.y + y, self.w, self.h)
end

function Text:colorindex(i) 
	if self.col == self.colors[i] then return end
	self.col = self.colors[i]
	txt_style(self.elem, self:getStyle())
end

function Text:colorhtml(c) 
	local h = htmlcolor(c)
	if self.col == h then return end
	self.col = h
	txt_style(self.elem, self:getStyle())
end

function Text:text(text)
	if self.val == text then return end
	self.val = text
	txt_set(self.elem, text)
end

function Text:getStyle()
	return self.style .. self.col
end

function Text:showElem(show)
	if show == self.ve then return end
	if (show and self.vp) ~= (self.vp and self.ve) then
		visible(self.elem, show and self.vp)
	end
	self.ve = show
end

function Text:showPage(show)
	if show == self.vp then return end
	if (show and ve) ~= (self.vp and self.ve) then
		visible(self.elem, show and self.ve)
	end
	self.vp = show
end

-- =========================================================== 

Group = {}
Group.__index = Group
function Group.new(elems, opt)
	local self = {vp = true, ve = true}
    setmetatable(self,Group)
	local tmp = {}
	for k,v in ipairs(elems) do
		tmp[k] = v.elem
	end
	self.elem = group_add(table.unpack(tmp))
	
	if PAGE ~= nil then PAGE:addElem(self, opt) end
    return self
end

function Group:showElem(show)
	if show == self.ve then return end
	if (show and self.vp) ~= (self.vp and self.ve) then
		visible(self.elem, show and self.vp)
	end
	self.ve = show
end

function Group:showPage(show)
	if show == self.vp then return end
	if (show and ve) ~= (self.vp and self.ve) then
		visible(self.elem, show and self.ve)
	end
	self.vp = show
end

-- ***** UTIL **********************************************
function limit(f, d, l)
	if l == nil then l = 1 end
	local s = tostring(math.floor(f * 10 ^ d + .5))
	
	while s:len() < d + l do s = "0" .. s end
	if d > 0 then
		return s:sub(1,s:len()-d) .. "." .. s:sub(s:len()-d+1)
	else
		return s
	end
end

function htmlcolor(i)
	return string.format("#%06x", i)
end

function convertString(str)
	print("==> ", str, " = ", string.byte(str, 1, string.len(str)))
	return string.gsub(str, "\195\130\194\176", "\194\176") -- replace "double" UTF 8 UTF (Â°) with UTF 8 (°)
end