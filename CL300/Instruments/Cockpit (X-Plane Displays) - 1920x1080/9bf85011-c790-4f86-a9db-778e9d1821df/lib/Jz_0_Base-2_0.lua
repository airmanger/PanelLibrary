-- NOTE: For a tutorial on how to use the library see http://forums.x-plane.org/index.php?showtopic=85916


--[[
Changes in Version 1.3:
- Removed the support for custom cursors, we're going touchscreen all the way!
- Changed the way how multi-image Icon-Objects are created. Now there is a common filename containing a placeholder (##) as well as a table of keys to replace the placeholders.
- The Icon-Object will now read the image resolution from the given (first) file.
- Icons for LEDs now always require that the Icon defines an OFF-Image (though this may be nil).
- Created ImageInstance class for images with different levels of illumination.
- Changed on how panels implement panes. Now panes aren't generic anymore. Instead there is a fixed default pane and a optional zoomed pane.

+++++ PLANNED ++++++  
- Redo PageButton Code: Use Airmanager Commands instead!
- Page/Panel: GroupCode
- PanelType/Elements/Icons: Code for multiple brightness levels
- Panel: Add support for Backlight-LED
  -> PanelType should support definition of threshold, dataref, offset and filepattern
- LitSwitches/Buttons: 
  -> create the switch and led(s), then add a led property to the switch
  -> adjust the default callback to handle leds
  -> think about the LitSwitch:show logic!!!!

Changes in Version 1.2:
- Added global variable DIAL_SIZE (defaults to 2) as a additional global zoom factor for dials (therefore the default dial is twice the icon size).
- The default drawback for Encoders (switch or rotate) now depends on the image count of the icon and not on the angle.
  Therefore it's possible to create multi-image encoders and still set the angle (relevant for the touch interface for the dial).
- LEDType now supports leds with N images and N thresholds (so with no OFF image). Previously LEDTypes required an OFF-image if
  they had more then one ON image.
- Added a property "link2bus" to all type objects (defaulting to "true" for LEDType, EncoderType, KeyType and SegemntType and "false" otherwise).
  When linking a whole panel to an dynamic bus only the link2bus instances are linked to the bus. 
- Page: Add support for non-fullscreen pages.
- KeyType: Support for static images (e.g. for pushbuttons on encoders)
- New PageButton concept
- Removed the support for panel popups on fixed position


Changes in Version 1.1:

- Rotary switches and encoders can now use dials (with support for touch-gestures and mousewheel) instead of buttons. You can
  globally disable this by setting the variable CLASSIC_BUTTONS to true.
  By default, encoders and switches with angle <> 0 use dials. You can override this by passing "dial = true/false" in the options/override-table.
  In addition, AM datarefs/commands are now supported as well, so if you want a switch to link to a instrumen instead of x-plane, go ahead.
  
- General change on how commands, datarefs and dataref types are handled. Instead of passing a string for the dataref/command name
  as well as a string for the datatype (or "CMD" for commands) you must use the DataRef/Command classes. 
  By this a LED can be linked to both a INT and a FLOAT dataref.

- All Types:   Removed keyword argument. The keyword should instead be set in the options- or override-table. While the keyword was needed for
               about 90% of the switches for the CL300 (lots of PBAs), in many other cases (e.g. x737 radio stack) it isn't needed. Also, that 
               way you can define a default keyword.

- EncoderType: New class to differentiate from rotary switches.

- GaugeType:   Now supports custom calculations for non-linear gauges without defining a complete updateCallback-Function.

- LEDType:     Now supports custom calculations for complex multi dataref leds without defining a complete updateCallback-Function.
               Now supports evaluation of multiple datarefs with mutliple thresholds.
               Now supports the "inverted"-parameter.
               
- StaticType:  New class for static images, e.g. to layer shadow overlays between inner and outer encoders.

- SegmentType: New class for 7/16-Segment-Displays (actually any kind of font display). 

- DynamicBus:  New class to collectively disable/enable segment displays, leds, dials (encoders) and pushbuttons only if the respective 
               bus or device (e.g. radio) is powered. For example, pressing the swap frequencies button on a radio unit while it is not
               powered should not swap the frequencies.

- Logic:       New class to link multiple datarefs to each other so you can define how A changes in case of a change in B or C and vice
               versa. If you have two switches controlling a single dataref. 
               Example: On the x737 ADF panel the power switch sets the dataref to 0 (off) or 1/2 otherwise and the ant/adf switch toggles
               the dataref between 1 (ant) and 2 (adf) (if on) or does nothing (off). Now you can just create two AM datarefs for the switches 
               and link both with the x-plane dataref via a Logic-object.

Known issues:
- Momentary switches don't work in dial-mode. The reason for this is that there is no unpressCallback to trigger the release of the dial!

--]]

--[[ CONSTANTS ************************************************************************ --]]
KIND_AM = 1 -- AM Dataref/Command
KIND_XP = 2 -- XP Dataref/Command
KIND_IN = 3 -- Internal Command

TYPE_TG = 1 -- Toggle/Push 
TYPE_DN = 2 -- Down/Decrease/Left
TYPE_UP = 3 -- Up/Increase/Right
TYPE_NO = 4 -- No action

WIDTH    = instrument_prop("PREF_WIDTH")
HEIGHT   = instrument_prop("PREF_HEIGHT")
DEBUG    = instrument_prop("DEVELOPMENT") -- enable logging, call own update()-function when changing a dataref

INTERNAL_DATAREFS = {}
INTERNAL_COMMANDS = {}

-- EMPTY: Transparent image to be used for the invisible buttons.
EMPTY = "EMPTY.png"
-- DIAL: Transparent image to be used for the invisible dials.
DIAL  = "!EMPTY.png"

-- ALLOW_REVERSE: If this is set to true, the up/down button will move the switch in the 
-- opposite direction (down/up) if the switch is already at its end of its movement. 
ALLOW_REVERSE = false
-- CLASSIC_BUTTONS: If this is set to true, encoders and rotary switches will use the old button interface.
CLASSIC_BUTTONS = false
-- DIAL_SIZE: This can be used to change the size of all dial objects.
DIAL_SIZE = 2
-- ENABLE_SOUNDS
ENABLE_SOUNDS = true

-- Reset this with a LightingType object before creating element types
DEFAULT_LIGHTING_TYPE = nil

DEBUG_COUNT = 0

function dlog(str) 
	if not DEBUG then return end
	print(string.format("%08d", DEBUG_COUNT) .. "> " .. str)
	DEBUG_COUNT = DEBUG_COUNT+1
end

--[[ LIGHTING TYPE  ************************************************************************
LightingType objects used to link the active and passive panel lighting to datarefs. Each
object specifies a different set. One might have one object for all panels where the backlight
is linked to the left bus, another one where the backlight is linked to the right bus and a 
third for the brightness of seven segment displays. 
LightingType must be linked to AM INT datarefs. You can link these to XP dataresf via the Logic-object.
--]]
LightingType = {}
LightingType.__index = LightingType

--[[ LightingType.new(...)
  Create the object.
size:               text size
alignment:          alignment
color:              text color
width/height:       icon/image width/height
--]]
function LightingType.new(pRef, pSuffixes, aRef, aSuffixes, tRef, tBrightness)
    local self = {images = {}, texts = {}, 
		passiveSuffixes = pSuffixes,   passiveVal = 0,
		activeSuffixes  = aSuffixes,   activeVal  = 0,
		textBrightness  = tBrightness, textVal    = 0}
    setmetatable(self,LightingType)
	-- create callbacks
	if pRef ~= nil then 
		am_variable_subscribe(pRef.name, pRef.datatype, function(val) self:updatePassiveImageBrightness(val) end)
	end
	if aRef ~= nil then 
		am_variable_subscribe(aRef.name, aRef.datatype, function(val) self:updateActiveImageBrightness(val) end)
	end
	if tRef ~= nil then 
		am_variable_subscribe(tRef.name, tRef.datatype, function(val) self:updateTextBrightness(val) end)
	end
    return self
end

function LightingType:addImage(img)
	img:setPassive(self.passiveVal)
	img:setActive(self.activeVal)
	table.insert(self.images, img)
end

function LightingType:addText(txt)
	txt:setBrightness(self.textBrightness[self.textVal])
	table.insert(self.texts, txt)
end

function LightingType:updateActiveImageBrightness(val)
	self.activeVal = val
	for k,v in pairs(self.images) do
		if v.setActive ~= nil then v:setActive(val) end
	end
end

function LightingType:updatePassiveImageBrightness(val)
	self.passiveVal = val
	for k,v in pairs(self.images) do
		if v.setPassive ~= nil then v:setPassive(val) end 
	end
end

function LightingType:updateTextBrightness(val)
	self.textVal = val
    for k,v in pairs(self.texts) do
		if v.setBrightness ~= nil then v:setBrightness(self.textBrightness[val]) end
	end
end

function LightingType:setAll()
	for k,v in pairs(self.images) do
		if v.setActive ~= nil then v:setActive(self.activeVal) end
	end
	for k,v in pairs(self.images) do
		if v.setPassive ~= nil then v:setPassive(self.passiveVal) end 
	end
	for k,v in pairs(self.images) do
		if v.setBrightness ~= nil then v:setBrightness(self.textVal) end
	end
end

--[[ HELPER FUNCTIONS *********************************************************************** --]]
-- Helper function to select the correct callback:
function setCallback(cbtype, inst, typedef, default)
    if inst[cbtype] == nil then 
        if typedef[cbtype] ~= nil then
            inst[cbtype] = typedef[cbtype]
        else
            inst[cbtype] = default
        end
    end
end

-- Helper function to check a threshold:
function checkThreshold(val, threshold, invert) 
    if type(val) == "nil" then val = 0 end
    if type(threshold) ~= "table" then
        if invert then
            return (val < threshold) and 2 or 1
        else
            return (val >= threshold) and 2 or 1
        end
    end
    if invert then
        for k = 1, #threshold do
            if val < threshold[k] then return k end
        end
        return #threshold+1
    else
        for k = #threshold, 1, -1 do
            if val >= threshold[k] then return k+1 end
        end
        return 1
    end
end

-- Extract digit
function getDigit(val, n) 
    local f = 10 ^ (n - 1)
    return math.floor(val % (f * 10) / f)
end

-- Set digit
function setDigit(val, n, digit)
    local f = 10 ^ (n - 1)
    return math.floor(val / (f*10)) * (f*10) + digit * f + val % f
end

-- Cycle var
function var_cycle(val, minval, maxval)
    if val < minval then
        return val + maxval - minval
    elseif val >= maxval then
        return val - maxval + minval
    else
        return val
    end
end

--[[ RECTANGLE ************************************************************************* --]]
Rectangle = {}
Rectangle.__index = Rectangle
function Rectangle.new(x, y, width, height)
    local self = {
		x   = x,
		y   = y,
		width   = width,
		height   = height
	}
    if type(files) == "table" then self.files = files else self.files = {files} end
    setmetatable(self,Rectangle)
    return self
end

--[[ ICON ************************************************************************
A icon is the collection of one or more related images, the (default) dimensions of 
the image and up to three rectangles for the button locations (toggle, down, up). 
If a instance of a switch using an icon only has two valid positions (or down/up aren't defined) 
then a single toggle button is created. Otherwise separate down- and up-buttons are created. 
That way you can use a single icon to create both a two- and three-position toggle switch.
--]]
Icon = {}
Icon.__index = Icon

--[[ Icon.new(...)
  Create the icon object.
basefile:           Basename of the file(s), without the file extension (.png).
					If the icon only contains one image, then this is the filename, otherwise 
					basefile should contain ## as a placeholder and the (optional) parameter 
					keys must be set to a table. In this case, one image per entry in the 
					table will be created with the value replacing the placeholder.
					Basefile may include an additional placeholder <SAMPLE> which may 
                    later be changed against another keyword when instancing the icon.
					In this case, SAMPLE must be a valid keyword so the size of the image
					can be determined.
                    If you have a file "LED RED.png" and a file "LED GREEN.png" you 
                    can use the filename "LED <RED>" to create a single icon object 
                    for both a red and green led. All extending classes (LED, Switch) 
                    support selecting the correct image by supplying a keyword as 
                    additional argument.
keys:				Keys for multi-image icons. If a certain value should not have a icon 
					image, don't set the keyword to nil but to "##" instead.
zoom:       		Optional (default) zoom factor for the images. Defaults to 1.
cltoggle/down/up:   Optional Rectangle-Objects to describe the button areas of the icon
                    cltoggle defaults to a Rectangle spanning the whole icon size
                    cldown/clup default to nil (no down/up-buttons)
--]]
function Icon.new(basefile, keys, zoom, cltoggle, cldown, clup)
	if type(zoom) ~= "number" then
		clup     = cldown
		cldown   = cltoggle
		cltoggle = zoom
		zoom     = 1
	end
	
	local files = {}
	local width  = 0
	local height = 0
	if basefile ~= nil then
		local sample = nil
		if string.find(basefile, "<") ~= nil then
			sample   = string.gsub(string.gsub(basefile, "^.-<", ""), ">.*", "")
			basefile = string.gsub(basefile, "<.*>", "%%%%")
		end
		if keys == nil then
			table.insert(files, basefile)
		else
			for k,v in pairs(keys) do
				if v == "##" then
					table.insert(files, "")
				else
					local f = string.gsub(basefile, "##", v)
					table.insert(files, f)
				end
			end
		end
		for k,v in pairs(files) do
			if v ~= nil then
				local f = v
				if sample ~= nil then f = string.gsub(v, "%%%%", sample) end
				local resinf = resource_info(f..".png")
				if resinf ~= nil then
					width  = resinf.WIDTH * zoom
					height = resinf.HEIGHT * zoom
					break
				end
			end
		end
	end
	
	local self = { files = files, width = width, height = height, clickareas = {} }
    if cltoggle ~= nil then
        self.clickareas[TYPE_TG] = cltoggle
    else
		if width > 0 and height > 0 then
			self.clickareas[TYPE_TG] = Rectangle.new(0,0,width,height)
		end
    end
    self.clickareas[TYPE_DN] = cldown
    self.clickareas[TYPE_UP] = clup
    
    setmetatable(self,Icon)
    return self
end

--[[ Icon:count()
  Returns the number of files/images.
--]]
function Icon:count()
	return #self.files
end

--[[ Icon:hasUpDown()
  Check if the icon has defined rectangles for up/down buttons.
--]]
function Icon:hasUpDown()
	return self.clickareas[TYPE_DN] ~= nil and self.clickareas[TYPE_UP] ~= nil
end

--[[ Icon:createVisuals(...)
  Creates the image(s) at the given position. 
page:               Page or ZoomedPanel
x/y:	            Center position
keyword:            Optional keyword to replace %% in the filename
zoom:               Optional zoom factor to rescale the images (e.g. for zoomed panels)
--]]
function Icon:createVisuals(page, lighttype, x, y, zoom, keyword)
    
	if self.files == nil then
		return nil
	else
		if zoom == nil then zoom = 1 end
		x = x - math.floor(self.width * zoom * .5)
		y = y - math.floor(self.height * zoom * .5)
		return ImageInstance.new(page, lighttype, x, y, self.width * zoom, self.height * zoom, self.files, keyword)
	end
end

--[[ Icon:createButton(...) 
  Creates a button at the given position. 
page:               Page or ZoomedPanel
x/y:	            Center position
btntype:            Type-Constant (TYPE_TG, TYPE_UP, TYPE_DN) to select the button to be created
clickcallback:      Callback-function for the click/press events of the button
releasecallback:    Optional callback-function for the depress event of the button
--]]
function Icon:createButton(page, x,y, zoom, btntype, clickcallback, releasecallback)
    a = self.clickareas[btntype]
    if a == nil then return nil end
    x = x + a.x*zoom - math.floor(a.width*zoom*.5)
    y = y + a.y*zoom - math.floor(a.height*zoom*.5)
    local width = (a.width > 0 and a.width or self.width)*zoom
    local height = (a.height > 0 and a.height or self.height)*zoom
    
    btn = button_add(EMPTY, EMPTY, x, y, width, height, clickcallback, releasecallback)
	page:addElem(btn)
	if not page.visible then visible(btn, false) end
	return btn
end

--[[ Icon:createDial(...) 
  Creates a button at the given position. 
page:               Page or ZoomedPanel
x/y:	            Center position
angle:              Angle of rotation for touch gesture
clickcallback:      Callback-function for the click/press events of the button
--]]
function Icon:createDial(page, x,y, zoom, angle, clickcallback)
    a = self.clickareas[TYPE_TG]
    if a == nil then return nil end
    
    local width = (a.width > 0 and a.width or self.width)*zoom*DIAL_SIZE
    local height = (a.height > 0 and a.height or self.height)*zoom*DIAL_SIZE
    x = x + a.x*zoom - math.floor(width*.5)
    y = y + a.y*zoom - math.floor(height*.5)
    
    dial = dial_add(DIAL, x, y, width, height, clickcallback)
	touch_setting(dial, "ROTATE_TICK", angle)
    page:addElem(dial)
	if not page.visible then visible(dial, false) end
	return dial
end

--[[ TEXT FIELD ************************************************************************
TextField objects are similar to the icon objects but handle text output only. 
--]]
TextField = {}
TextField.__index = TextField

--[[ TextField.new(...)
  Create the object.
size:               text size
alignment:          alignment
color:              text color
width/height:       icon/image width/height
--]]
function TextField.new(font, size, alignment, color, width, height)
    local self = { width = width, height = height, font = font, size = size, color = color, alignment = alignment }
    setmetatable(self,TextField)
    return self
end

function TextField:count()
	return 1
end

--[[ TextField:createVisuals(...)
  Creates the image(s) at the given position. 
page:               Page or ZoomedPanel
x/y:	            Center position
zoom:               Optional zoom factor to rescale the images (e.g. for zoomed panels)
--]]
function TextField:createVisuals(page, lighttype, x, y, zoom, keyword)
    if zoom == nil then zoom = 1 end
    x = x - math.floor(self.width * zoom * .5)
    y = y - math.floor(self.height * zoom * .5)
	local bs = "-fx-font-family:\"" .. self.font .. "\"; -fx-font-size:" .. math.floor(self.size * zoom) .. "px; -fx-text-alignment: " .. self.alignment .. "; -fx-fill: "
	return TextInstance.new(page, lighttype, x, y, self.width * zoom, self.height * zoom, bs, self.color)
end

--[[ IMAGE INSTANCE ************************************************************************
A collection of images created by an Icon-object containing all differnt states and rotations.
Uses the global vars ACTIVE/PASSIVE_LIGHT_SUFFIX and ACTIVE/PASSIVE_LIGHT_DATAREF to automatically
create callback handlers to switch image visiblity when lighting changes.
--]]
ImageInstance = {}
ImageInstance.__index = ImageInstance

--[[ ImageInstance.new(...)
  Create the ImageInstance object.
--]]
function ImageInstance.new(page, lighttype, x, y, width, height, files, keyword)
	local self = {page = page, count = #files, selected = 1, enabled = true, rotation = 0, passive = 0, active = 0, images = {active = {}, passive = {}}}
    setmetatable(self,ImageInstance)
	
	local psuffix = nil
	local asuffix = nil
	if lighttype ~= nil then
		psuffix = lighttype.passiveSuffixes
		asuffix = lighttype.activeSuffixes
	else
		psuffix = {""}
	end
	-- Create images
	for k,v in pairs(files) do
		local imgs = {passive = {}, active = {}}
		local file = (keyword ~= nil and string.gsub(v, "%%%%", keyword) or v)
		self.images[k] = {passive = self:createSet(psuffix, file, x, y, width, height),
						  active  = self:createSet(asuffix, file, x, y, width, height)}
	end
	
	if lighttype ~= nil then
		lighttype:addImage(self)
	end
    return self
end

-- internal func
function ImageInstance:createSet(tbl, file, x, y, width, height)
	if tbl == nil then return nil end
	local imgs = {}
	for k,v in pairs(tbl) do
		if file == "" then
			table.insert(imgs, nil)
		else	
			local fn = file .. v .. ".png"
			local ri = resource_info(fn)
			if ri == nil then -- light level not defined for this type of controls
				break
			else
				local id = img_add(fn, x, y, width, height)
				visible(id, false)
				table.insert(imgs, id)
			end
		end
	end
	return imgs
end

-- internal func
function ImageInstance:getActive()
	if self.selected == 0 or self.active == 0 then return nil end
	local m = self.images[not self.enabled and 1 or self.selected]
	if m == nil then return nil end
	return m.active[math.min(self.active, #m.active)]
end

-- internal func
function ImageInstance:getPassive()
	if self.selected == 0 or self.passive == 0 then return nil end
	local m = self.images[not self.enabled and 1 or self.selected]
	if m == nil then return nil end
	return m.passive[math.min(self.passive, #m.passive)]
end

function ImageInstance:setActive(i) 
	if self.active == i then return end
	local s = self.selected
	local m = self.images[not self.enabled and 1 or self.selected]
	if m ~= nil and m.active ~= nil then
		local old = math.min(self.active,#m.active)
		local new = math.min(i, #m.active)
		if old ~= new then
			self:select(0)
			self.active = i
			self:select(s)
			return
		end
	end
	self.active = i
end

function ImageInstance:setPassive(i) 
	if self.passive == i then return end
	local s = self.selected
	local m = self.images[not self.enabled and 1 or self.selected]
	if m ~= nil and m.passive ~= nil then
		local old = math.min(self.passive,#m.passive)
		local new = math.min(i, #m.passive)
		if old ~= new then
			self:select(0)
			self.passive = i
			self:select(s)
			return
		end
	end
	self.passive = i
end

-- internal func
function ImageInstance:visible(v)
	self.page:toggleElem(self:getActive(), v)
	self.page:toggleElem(self:getPassive(), v)
end

function ImageInstance:rotate(r)
	local id = self:getActive()
	if id ~= nil then img_rotate(id, r) end
	id = self:getPassive()
	if id ~= nil then img_rotate(id, r) end
	self.rotation = r
end

function ImageInstance:select(s)
	if self.selected == s then return end
	local r = self.rotation
	if self.selected > 0 then
		if r ~= 0 then self:rotate(0) end
		self:visible(false)
		self.selected = 0
	end
	if s > 0 then
		self.selected = s
		self:visible(true)
		self:rotate(r)
	else
		self.rotation = r
	end
end

function ImageInstance:enable(e)
	if self.enabled == e then return end
	if self.selected == 1 then -- on "enabled" == 1, 1 will be "selected" so when toggling "enabled" while "selected" == 1, no image will be changed
		self.enabled = e
	else
		self:visible(false)
		self.enabled = e
		self:visible(true)
	end
end

--[[ TEXT INSTANCE ************************************************************************
TextInstance objects are similar to the ImageInstance objects but handle text output. 
--]]
TextInstance = {}
TextInstance.__index = TextInstance

--[[ TextInstance.new(...)
  Create the object.
--]]
function TextInstance.new(page, lighttype, x, y, width, height, basestyle, color)
	local self = {basestyle = basestyle, enabled = true, color = color, brightness = 0, colorfinal = "#000000"}
	setmetatable(self,TextInstance)
    
	self.txt = txt_add(" ", self:getStyle(), x, y, width, height)
	page:addElem(self.txt)
	if not page.visible then visible(self.txt, false) end
	
	if lighttype ~= nil then
		lighttype:addText(self)
	end
	
	return self
end

-- internal func
function TextInstance:getStyle() 
	return self.basestyle .. self.colorfinal .. ";"
end

function TextInstance:setBrightness(i)
	if self.brightness == i then return end
	self.brightness = i
	self:updateColor()
end

function TextInstance:setColor(c)
	if c == nil then c = 0 end
	if self.color == c then return end
	self.color = c
	self:updateColor()
end

function TextInstance:updateColor()
	if self.brightness == 0 or self.color == nil then
		self.colorfinal = "#000000"
	else
		local r = math.floor(self.color / 65536)
		local g = math.floor(self.color / 256) % 256
		local b = self.color % 256
		self.colorfinal = string.format("#%02X%02X%02X", math.floor(r * self.brightness), math.floor(g * self.brightness), math.floor(b * self.brightness))
	end
	txt_style(self.txt,self:getStyle())
end

function TextInstance:setText(str)
	txt_set(self.txt, str)
end

function TextInstance:enable(e)
	if self.enabled == e then return end
	self.enabled = e
	self.page:toggleElem(self.txt, e)
end

--[[ CONTROL INSTANCE ************************************************************************
A collection of buttons/dials on a page.
--]]
ControlInstance = {}
ControlInstance.__index = ControlInstance

--[[ ControlInstance.new(...)
  Create the ControlInstance object.
--]]
function ControlInstance.new(page)
	local self = {page = page, enabled = true, items = {}}
    setmetatable(self,ControlInstance)
    return self
end

function ControlInstance:add(key, item)
	self.items[key] = item
	-- Will be done in Icon.createButton/createDial
	--if self.enabled then 
	--	self.page:addElem(item)
	--end
	--visible(self.page.visible and self.enabled)
end

function ControlInstance:get(key)
	return self.items[key]
end

function ControlInstance:enable(e)
	if self.enabled == e then return end
	self.enabled = e
	for k,v in pairs(self.items) do
		self.page:toggleElem(v, e)
	end
end

--[[ BASE INSTANCE ************************************************************************
BaseInstance is the basic element instance class. Usually you shouldn't have to manually 
use this class. The instances are created and controlled by the type- and panel-classes.
--]]
BaseInstance = {}
BaseInstance.__index = BaseInstance
--[[ BaseInstance.new(...)
  Create the object.
def:        Type-object that is creating this instance.
dataref:    Either a single dataref as string or a table of datarefs.     
override:   Optional table to override properties of the type-object.
--]]
function BaseInstance.new(def,dataref,override)
    if     dataref == nil           then dataref = {}
    elseif dataref.isCommand ~= nil then dataref = {dataref} end
    
    local self = {
        name              = dataref[1],
        def               = def,
		occurances        = {},
        dataref           = dataref, 
        index             = nil, 
        values            = {}, 
        valueCount        = 0,
        linked            = true, -- Switch and dataref are linked (e.g. rotary switch, toggle switch)
        position          = 0,    -- Position of switch, can differ from the dataref value (e.g. encoders, unpowered pushbuttons)
        interval          = 0,
        tic               = 0,
        lastTime          = 0,
		lastDir           = 0,
		ispowered         = true,
		islocked          = false,
        keyword           = nil, 
		guardedInst       = {},
		guardingInst      = nil,
		updateCallback    = nil,
        pressedCallback   = nil,
        releaseCallback   = nil,
        subscribe         = true,
        parent            = nil
    }    
    
    if #dataref > 0 and dataref[1] ~= nil then
        self.name    = dataref[1].name
        self.command = dataref[1]:isCommand()
    else
        self.name    = "-none-"
        self.command = false
    end
    for k,v in pairs(dataref) do
		if v.datatype ~= nil and v.datatype:sub(1,4) == "BYTE" then
			table.insert(self.values, {})
		else
			table.insert(self.values, 0)
		end
    end
        
    -- copy default properties from def:
    for k,v in pairs(self.def) do
        if type(v) == "number" or type(v) == "boolean" or type(v) == "string" then 
            self[k] = v
        end
    end
    if type(self.def.threshold) == "table" then
        self.threshold = self.def.threshold
    end
	self.icon          = self.def.icon
    self.momentary     = self.def.momentary
    self.custom        = self.def.custom
    self.customValues  = self.def.customValues
    self.guardingInst  = self.def.guardingInst
    self.selectingInst = self.def.selectingInst
	self.lightingType  = self.def.lightingType
	
    -- override defaults:
    if type(override) == "table" then
        for k,v in pairs(override) do
            self[k] = v
        end
    end
    self.imgCount = self.icon:count()
	
	if self.lightingType == nil then self.lightingType = DEFAULT_LIGHTING_TYPE end
    
	if self.step == nil then self.step = 0 end
    if self.step ~= 0 and self.maxval ~= nil and self.minval ~= nil then
        -- we use 1.001 to take care of rounding issues with steps < 1... we don't want 20.00001 values!   
        self.valueCount  = math.abs(math.floor(1.00001 + (self.maxval - self.minval) / self.step))
    else
        self.valueCount = -1
    end
    if self.valueCount < 2 and self.valueCount ~= -1 then
        self.subscribe = false
    end
    
    if self.dial and not CLASSIC_BUTTONS then
        self.interval = 0
        if self.angle == 0 then self.angle = 45 end -- default angle for multi image switches
    else
        self.dial = false
    end
    
    if self.threshold == nil then 
        self.inverted = (self.step < 0)
    end
    
    setmetatable(self,BaseInstance)
    
    -- subscribe datarefs
    if self.command then
        self.linked = false
    elseif self.subscribe then
        for k,v in pairs(self.dataref) do 
            if v ~= nil then v:subscribe(self, k) end 
        end
    end
    return self
end	

function BaseInstance:getOcc(page)
	local occ = self.occurances[page.id]
	if occ == nil then
		occ = {page = page}
		self.occurances[page.id] = occ
	end
	return occ
end

--[[ BaseInstance:create(...)
  Create/deploy the instance on a pane.
id:         Name/ID of the pane of the instance (default, zoomed). 
x/y/zoom:   Absolute position and zoom to be passed to the Icon for 
            image/button creation.
--]]
function BaseInstance:createVisuals(page,x,y,zoom)
	local imgs = self.icon:createVisuals(page, self.lightingType, x, y, zoom, self.keyword)
	if imgs ~= nil then
		local occ = self:getOcc(page)
		occ.images = imgs
	end
	self:update()
end

function BaseInstance:createControls(page,x,y,zoom)
    if self.pressedCallback == nil then 
		return
	end
	
	local occ = self:getOcc(page)
	local set = ControlInstance.new(page)
	occ.controls = set
	
	local dirs
	if self.dial then
		dirs = {[TYPE_TG] = 2}
		local inst = {obj = self, impl = self.pressedCallback, release = self.releaseCallback}
		inst.implDial = function(dir) inst.impl(inst.obj, dir) end
		set:add(TYPE_TG, self.icon:createDial(page, x, y, zoom, self.angle, inst.implDial))
	else
		if self.valueCount == 2 then 
			dirs = {[TYPE_TG] = 0}
		elseif not self.icon:hasUpDown() then
			dirs = {[TYPE_TG] = (self.step > 0 and 1 or -1)}
		else	
			dirs = {[TYPE_DN] = -1, [TYPE_UP] = 1}
		end
		
		for k,v in pairs(dirs) do
			local inst = {obj = self, impl = self.pressedCallback, release = self.releaseCallback}
			inst.implDir = function() inst.impl(inst.obj, v) end
			if self.interval == 0 then 
				inst.pushed = inst.implDir
				if type(self.momentary) == "table" then
					inst.released = function() inst.release(inst.obj) end
				end
			else 
				inst.interval = self.interval
				inst.pushed   = function() inst.timer = timer_start(0, inst.interval, inst.implDir) end
				inst.released = function() timer_stop(inst.timer); inst.obj.tic = 0 end
			end
			set:add(k, self.icon:createButton(page, x, y, zoom, k, inst.pushed, inst.released))
		end
	end
	set:enable(not self.islocked)
end

function BaseInstance:rotate(rot)
	if ENABLE_SOUNDS and self.sound ~= nil then
		sound_play(self.sound)
	end
    for k,v in pairs(self.occurances) do
		v.images:rotate(rot)
	end
end

function BaseInstance:select(sel)
	if ENABLE_SOUNDS and self.sound ~= nil then
		sound_play(self.sound)
	end
	for k,v in pairs(self.occurances) do
		v.images:select(sel)
	end
end

function BaseInstance:setText(str)
	for k,v in pairs(self.occurances) do
		v.images:setText(str)
	end
end

function BaseInstance:setColor(c)
	for k,v in pairs(self.occurances) do
		v.images:setColor(c)
	end
end

--[[ BaseInstance:update(...)
  Automatically called when the dateref(s) change.
index:      Index of changed dataref
val:        New dataref value
--]]
function BaseInstance:update(valpos, val)
    if valpos ~= nil then
        self.values[valpos] = val
        if self.linked and valpos == 1 then
            self.position = val
        end
    elseif self.linked then
        self.position = self.values[1]
    end
    
	if self.guardingInst ~= nil and self.guardingInst.closepos ~= nil then
		self.guardingInst:lock(self:getValue() ~= self.guardingInst.closepos)
	end
	if self.updateCallback ~= nil then self.updateCallback(self) end
end

--[[ BaseInstance:getValue(...)
  Get the value of the element.
--]]
function BaseInstance:getValue()
    return self.values[1]
end

--[[ BaseInstance:getPosition(...)
  Get the position of the element.
--]]
function BaseInstance:getPosition()
    return self.position
end

--[[ BaseInstance:upperLimit(...)
  Element is at it's upper limit (value = maxvalue).
--]]
function BaseInstance:upperLimit() 
    if self.inverted then return self:getValue() <= self.minval end
    return self:getValue() >= self.maxval
end

--[[ BaseInstance:lowerLimit(...)
  Element is at it's lower limit (value = minvalue).
--]]
function BaseInstance:lowerLimit() 
    if self.inverted then return self:getValue() >= self.maxval end
    return self:getValue() <= self.minval
end

--[[ BaseInstance:lock(...)
  Disable element, if it's mechanically blocked (e.g. protect by guard)
--]]
function BaseInstance:lock(l) 
	if self.islocked == l then return end
    self.islocked = l
	if self.occurances ~= nil then
		for k,v in pairs(self.occurances) do
			if v.controls ~= nil then
				v.controls:enable(not l)
			end
		end
	end
end

function BaseInstance:addGuardedInst(guardedInst)
	table.insert(self.guardedInst, guardedInst)
	guardedInst.guardingInst = self
end

--[[ BaseInstance:power(...)
  Enable or disable element, if it's not powered (dials will still turn but do nothing!)
--]]
function BaseInstance:power(powered)
	if self.ispowered == powered then return end
	self.ispowered = powered
	self:update()
end

--[[ BaseInstance:sendValue(...)
  Send dataref change or command to the simulator.
val: Value for datarefs
dir: Direction for commands
--]]
function BaseInstance:sendValue(val, dir) 
    for k,v in pairs(self.dataref) do
		if v:isCommand() then
			v:invoke(dir)
		else
			v:write(val)
		end
    end
end 

--[[ BaseInstance:setParent(...)
  Send parent panel.
val: Value for datarefs
dir: Direction for commands
--]]
function BaseInstance:setParent(panel) 
    self.parent = panel
end 

--[[ BASE TYPE ************************************************************************
Abstract element type base class to set default values for all deriving element types 
(LED Type, Switch Type, etc).
All deriving type classes should contain a function "createInstance(...)" to create 
instances of the element type.
--]]
BaseType = {}
BaseType.__index = BaseType
function BaseType.new(icon, opts)
    local self;
    if opts == nil then 
        self = {icon = icon} 
    else 
        self = opts
        self.icon = icon
    end
    -- defaults:
    if self.maxval   == nil then self.maxval   = 1 end
    if self.minval   == nil then self.minval   = 0 end
    if self.center   == nil then self.center   = (self.minval+self.maxval) / 2 end
    if self.cycle    == nil then self.cycle    = false end
    if self.step     == nil then self.step     = 1 end
    if self.interval == nil then self.interval = 0 end
    if self.tics     == nil then self.tics     = 0 end
    if self.factor   == nil then self.factor   = 5 end
    if self.angle    == nil then self.angle    = 0 end
    if self.dial     == nil then self.dial     = (self.angle ~= 0) end
    if self.digit    ~= nil then self.cycle    = true end -- enforce cycling in single digit mode
    if self.link2bus == nil then self.link2bus = false end 
    setmetatable(self,BaseType)
    return self
end

--[[ DEFAULT CALLBACK FUNCTIONS ****************************************************
Default callback functions that will be used by the specific elements. Usually you 
can get quite far without writing you own callbacks. 

DrawCallback-Functions are called by the show(), create() and update()-function to draw 
the element (if it is visible). 

PressedCallback-Functions are called by the buttons when they are pressed.

ReleaseCallback-Functions are called by the buttons when they are released, used
for momentary switches.

UpdateCallback-Functions are called by the update()-function when the dataref changes 
(independently of visibility)

The first argument is always the matching element-instance.
--]]

--[[ Default draw callback for segment displays
If neither pattern nor custom is defined, the (first) value is simply set. 
If pattern is set, string.format will be applied with that pattern and the given values.
If factors is defined as a table, the values are multiplied with the factors.
If custom is present, the function will be called with the current values instead.
If the instance is not powered, an empty text is drawn.
--]]
defaultUpdateCallbackSegment = function(inst)
	local str = "" 
    if inst.ispowered then 
        if inst.custom ~= nil then
			str = inst.custom(table.unpack(inst.values))
        elseif inst.pattern ~= nil then
            local tmp
            if type(inst.factors) == "table" then
                tmp = {}
                for k,v in pairs(inst.values) do
                    table.insert(tmp, v * (k > #inst.factors and 1 or inst.factors[k]))
                end
            else
                tmp = inst.values
            end
            str = string.format(inst.pattern, table.unpack(tmp))
        else
			str = inst:getValue()
        end
    end
	inst:setText(str)
end

--[[ Default draw callback for LEDS-style objects
If the Icon contains only one image (ON) the image is shown if the value is equal or 
above the configured threshold.
If the Icon contains two images (OFF, ON) the ON image is shown if the value is equal
or above the configured threshold, otherwise the OFF image is show.
If the Icon contains more then two images (OFF, ON-1, ON-2, ...) the control must have
a table of thresholds. The highest ON-image which has its threshold met will be shown,
otherwise the OFF-image will be shown.
If the instance is not powered, the OFF-image is drawn.
--]]
defaultUpdateCallbackThreshold = function(inst)
	local sel
    if not inst.ispowered then 
        sel = 1
    else
        if inst.custom ~= nil then
            sel = inst.custom(table.unpack(inst.values))
        elseif #inst.values == 1 then
            sel = checkThreshold(inst.values[1], inst.threshold, inst.inverted)
        else
            sel = ((not inst.inverted) and 9999 or 0)
            for i = 1, #inst.values do
                if inst.inverted then
                    sel = math.max(sel, checkThreshold(inst.values[i], inst.threshold[i], inst.inverted))
                else
                    sel = math.min(sel, checkThreshold(inst.values[i], inst.threshold[i], inst.inverted))
                end
            end
        end
    end
	inst:select(sel)
end

--[[ Default draw callback multi-image switch-style objects
If the number of possible values of the element matches the number of images, the 
selected image is shown.
Otherwise if the number of possible values is two then:
    - The last image will be shown if the value is maxval.
    - The first image will be shown if the value is minval.
    - If there is only one image, it will be shown at maxval.
The purpose of this special logic is to support using the same three-image icon 
for both two- and three-position toggle switches.
--]]
defaultUpdateCallbackSelect = function(inst) 
    local sel = nil
    -- multi image switch style default:
	if not inst.linked then 
        -- multi image encoder
        sel = (inst:getPosition() % inst.imgCount) + 1
	elseif inst.valueCount == inst.imgCount then
		sel = var_round((var_cap(inst:getPosition(), inst.minval, inst.maxval) - inst.minval) / inst.step + 1, 0)
	elseif inst.valueCount == 2 then
		-- default for 2 position toggles with 3 images 
		-- or pushbuttons with 1 image:
		if inst:getPosition() > inst.minval then 
			sel = inst.imgCount
		elseif inst.imgCount > 1 then
			sel = 1
		end
	else
		sel = var_round((inst:getPosition() - inst.minval) / inst.step + 1, 0)
	end
    if inst.inverted then sel = inst.imgCount - sel + 1 end
	inst:select(sel)
end

--[[ Default draw callback rotary switch/gauge-style objects
The image is rotated according to the minval, maxval, angle and center-properties.
If the instance has a custom function, it is called to calculate the correct angle of rotation.
--]]
defaultUpdateCallbackRotate = function(inst)
    local rot
    if inst.custom ~= nil then
        rot = inst.custom(table.unpack(inst.values))
    elseif not inst.linked then  -- no capping:
        rot = (inst:getPosition() - inst.center) * inst.angle / inst.step
    else 
        rot = (var_cap(inst:getPosition(),inst.minval,inst.maxval) - inst.center) * inst.angle / inst.step
    end
	inst:rotate(rot)
end

--[[ Default update callback  for guards
Update callback disabling the guarded element if the guard isn't at its maxval.
--]]
defaultUpdateCallbackGuard = function(inst)
    for k,v in pairs(inst.guardedInst) do
        v:lock(not inst:upperLimit())
    end
	defaultUpdateCallbackSelect(inst)
end

--[[ Default pressed callback 
Pressed callback considering switch limits, button inverting and cycling.
dir is the selected direction of movement (1 = up, -1 = down, 0 = toggle)
--]]
defaultPressedCallback = function(inst, dir)
	if inst.islocked then return end
    local val
    if inst.command then 
        val = inst:getPosition() 
    else
        val = inst:getValue()
    end
    if dir == 0 then
        if val == inst.minval then
            val = inst.maxval
            dir = 1
        else
            val = inst.minval
            dir = -1
        end
    elseif inst.digit ~= nil then
        local d = var_cycle(getDigit(val, inst.digit) + dir, inst.minval, inst.maxval)
        val = setDigit(val, inst.digit, d)
    else
        if inst.interval == 0 and not inst.cycle and not inst.command and ALLOW_REVERSE then
            -- reverse direction at ends for non-interval switches:
            if val <= inst.minval then
                dir = math.abs(dir)
            elseif val >= inst.maxval then 
                dir = - math.abs(dir)
            end
        end

		-- Coarse factor for dials:
		if inst.dial and inst.tics > 0 then
			local t = os.clock()
			if inst.lastDir == dir and (t-inst.lastTime) < 0.2 then -- within 200 ms
				inst.tic = inst.tic + 1
				if inst.tic > inst.tics then
					dir = dir * inst.factor
				end
			else
				inst.tic = 1
				inst.lastDir = dir
			end
			inst.lastTime = t
		end
        -- coarse factor
        if inst.interval > 0 and inst.tics ~= nil and inst.tics > 0 then
            inst.tic = inst.tic + 1
            if inst.tic > inst.tics then
                dir = dir * inst.factor
            end
        end
        -- final calculation, round to full numbers
        val = val + dir * inst.step
        local rnd = var_round(val,4)
        if (rnd % 1) == 0 then val = rnd end
        -- cycling/capping
        if inst.cycle then
            val = var_cycle(val, inst.minval, inst.maxval)
        else
            val = var_cap(val, inst.minval, inst.maxval)
        end
    end
    if #inst.guardedInst > 0 and inst.setonclose ~= nil and val < inst.maxval then
        for k,v in pairs(inst.guardedInst) do
            v:update(1, inst.setonclose)
        end
    end
    -- set position if not linked (encoders, command buttons)
    if inst.command then
        inst.position = val
    elseif not inst.linked then
        inst.position = inst:getPosition() + dir
    end
    if inst.ispowered then
        inst:sendValue(val, dir)
    end
    if DEBUG or not inst.linked then inst:update() end
end 	

--[[ Default release callback 
Released callback used for momentary buttons/switches
--]]
defaultReleaseCallback = function(inst)
    local val = inst.momentary[inst:getPosition()] 
    if type(val) ~= "nil" then
        if inst.ispowered then
            inst:sendValue(val, val < inst:getPosition() and -1 or 1) -- convert to direction
        end
        if not inst.linked then
            inst.position = val
        end
        if DEBUG or not inst.linked then inst:update() end
    end
end
    
--[[ STATIC TYPE ************************************************************************
StaticType is the class to create static images.
--]]
StaticType = {}
StaticType.__index = StaticType

--[[ StaticType.new(...)
  Create the type object.
icon:       Icon for the static image.
opts:       Table of options:
    keyword:    Default keyword to be passed to the icon-object when creating images.
--]]
function StaticType.new(icon, opts)
    local self = BaseType.new(icon, opts)
    setmetatable(self,StaticType)
    return self
end

--[[ StaticType:createInstance(...)
  Create a instance of this type.
keyword:    Keyword to be passed to the icon-object when creating images and used
            to replace the %% pattern.
--]]
function StaticType:createInstance(override)
	local inst = BaseInstance.new(self,nil,override)
	return inst
end

--[[ LED TYPE ************************************************************************
LEDType is the class to create types of LEDs, Annunciators and other objects which show different images depending on the value of a dataref.
--]]
LEDType = {}
LEDType.__index = LEDType

--[[ LEDType.new(...)
  Create the type object.
icon:       Icon for the led. May either just contain one image (on), two  images (off/on), or multiple images (e.g. off, dim, bright). 
opts:       Table of options:
    threshold:  Controls image visibility. If the LED-Instance is linked to multiple
                datarefs, this will be expected to be a table of threshold definitions,
                one for each dataref. Otherwise it should be a single threshold definition.
                A threshold definition should either be a single threshold value (if the 
                icon contains a single ON image or two images (OFF/ON), a table with N-1 
                threshold values if the icon contains N images (OFF/ON 1/ON 2/...) or
                a table with N threshold values if the icon contains N images (ON 1/ON 2/...).
                If multiple datarefs are linked, the thresholds are linked with MIN, so
                if the first dataref meets the 5th threshold and the second dataref meets 
                the 2nd, the image for the 2nd threshold will be selected.
    custom:     Function for extended threshold calculations. It will be called with all datarefs
                values as arguments and is expected to return a number of the selected image
                or nil if no image is to be shown.
    inverted:   Usually only used via override for single instances with a simple threshold: 
                Inverts the LED, so the ON image is shown when the threshold is not met!
                Defaults to false.
    keyword:    Default keyword to be passed to the icon-object when creating images.
    updateCallback:     Function called when the value/dataref has changed independently of 
                        item visibility. Defaults to defaultUpdateCallbackThreshold(...).
--]]
function LEDType.new(icon, opts)
    if opts == nil then opts = {} end
    if opts.threshold == nil then opts.threshold = 0.1 end
    if opts.link2bus == nil then opts.link2bus = true end
    local tc = 1
    if type(opts.threshold) == "table" then 
        if type(opts.threshold[1]) == "table" then
            tc = #opts.threshold[1]
        else
            tc = #opts.threshold
        end
    else 
        opts.threshold = {opts.threshold} 
    end
    local self = BaseType.new(icon, opts)
    setmetatable(self,LEDType)
    return self
end

--[[ LEDType:createInstance(...)
  Create a instance of this type.
dataref:    Dataref linked to this instance. This should usually be a string 
            (single dataref) but may also be a table of strings (multiple datarefs)
            if you are using custom callback functions.
override:   Optional table to override properties of the type definition for this
            specific instance, e.g. if you want to use a different threshold for 
            this instance only.
--]]
function LEDType:createInstance(dataref,override)
	local inst = BaseInstance.new(self,dataref,override)
    setCallback("updateCallback", inst, self, defaultUpdateCallbackThreshold)
	return inst
end

--[[ GAUGE TYPE ************************************************************************
GaugeType is the class to create analogue gauges. Note, if the gauge type isn't linear then you 
need to define a own callback function for the gauge type. There are two approaches for this:
Either you write your own (modified) drawCallback which directly handles the correct turning 
of the needle. In that case, the value stored in the instance will be the raw value from the 
sim. Or you can write a updateCallback function which converts the raw value of the sim to a 
linear value that is stored in this instance and used with the regular linear drawCallback.
--]]
GaugeType = {}
GaugeType.__index = GaugeType

--[[ GaugeType.new(...)
  Create the type object.
icon:       Icon for the gauge needle. 
opts:       Table of options:
    maxval:     Highest valid value. Defaults to 1.
    minval:     Lowest valid value. Defaults to 0.
    center:     The value that matches the image without rotation. Defaults to 
                (minval+maxval)/2.
    angle:      Define the level of rotation, a dataref change of 1 equals a rotation of
                'angle' deg. 
    custom:     Function for extended rotation calculations. It will be called with all datarefs
                values as arguments and is expected to return the angle of rotation.
    keyword:    Default keyword to be passed to the icon-object when creating images.
    updateCallback:     Function called when the value/dataref has changed independently of 
                        item visibility. Defaults to defaultUpdateCallbackRotate(...).
--]]
function GaugeType.new(icon, opts)
    local self = BaseType.new(icon, opts)
    setmetatable(self,GaugeType)
    return self
end

--[[ GaugeType:createInstance(...)
  Create a instance of this type.
dataref:    Dataref linked to this instance. This should usually be a string 
            (single dataref) but may also be a table of strings (multiple datarefs)
            if you are using custom callback functions.
override:   Optional table to override properties of the type definition for this
            specific instance, e.g. if you want to use a different angle for 
            this instance only.
--]]
function GaugeType:createInstance(dataref,override)
	local inst = BaseInstance.new(self,dataref,override)
    setCallback("updateCallback", inst, self, defaultUpdateCallbackRotate)
	return inst
end

--[[ SEGMENT TYPE ************************************************************************
GaugeType is the class to create (seven) segment displays.
--]]
SegmentType = {}
SegmentType.__index = SegmentType

--[[ SegmentType.new(...)
  Create the type object.
textfield:  Textfield for the display. 
opts:       Table of options:
    pattern:    Optional string format. If not defined, the value of the dataref will be 
                print without any conversion. 
                If pattern is set, string.format will be called with the pattern and 
                all dataref values. 
                Example: If you create a SegementType which will be linked to two datarefs
                (e.g. nav1_frequency_Mhz and nav1_frequency_khz), you could use the pattern
                "%03d.%02d" to print the frequency parts joined with a decimal point.
    factors:    Optional table of factors with which the datarefs are multiplied. Only used
                when pattern is set.
    custom:     Function for extended custom conversion. It will be called with all datarefs
                values as arguments and is expected to return a string or number.
    updateCallback:     Function called when the value/dataref has changed independently of 
                        item visibility. Defaults to defaultUpdateCallbackSegment(...).
--]]
function SegmentType.new(textfield, opts)
    if opts == nil then
        opts = {icon = textfield}
    else
        opts.icon = textfield
    end
    if opts.link2bus == nil then opts.link2bus = true end
    local self = opts
    setmetatable(self,SegmentType)
	if self.lightingType == nil then self.lightingType = DEFAULT_LIGHTING_TYPE end
    return self
end

--[[ SegmentType:createInstance(...)
  Create a instance of this type.
dataref:    Dataref linked to this instance. This should usually be a string 
            (single dataref) but may also be a table of strings (multiple datarefs)
            if you are using custom callback functions.
override:   Optional table to override properties of the type definition for this
            specific instance, e.g. if you want to use a different angle for 
            this instance only.
--]]
function SegmentType:createInstance(dataref,override)
	local inst = BaseInstance.new(self,dataref,override)
    setCallback("updateCallback", inst, self, defaultUpdateCallbackSegment)
	return inst
end

--[[ KEY TYPE  ************************************************************************
KeyType is the class to create (momentary) buttons or key which have their graphic embedded in 
the background and therefore don't have an own image. Therefore we also refer to them as "invisible" 
keys. 
--]]
KeyType = {}
KeyType.__index = KeyType
--[[ KeyType.new(...)
  Create the type object.
icon:       Icon to define the key dimensions, the filename of the icons image should be nil. 
opts:       Table of options:
    maxval:     Highest valid value. Defaults to 1.
    minval:     Lowest valid value. Defaults to 0. If the key should not toggle the value but instead 
                always set a certain fixed value (unless it's already set), like a button setting a 
                MFD to a certain screen (e.g. "fuel"), you can just set the minval to maxval.
    cycle:      Defines whether the control is cyclic (e.g. toggle map mode). Note that in 
                that case, you will need to increase maxval by one since maxval will never be reached.
    momentary:  Defines momentary positions and where the switch will move to once the 
                control is released. Default to nil (no momentary positions). Expects a
                table containing the momentary position(s) as key(s) and the positions to
                which the control moves as  value. 
                Example - Simple 0/1 pushbutton, setting 1 while pushed and 0 when released: 
                    {[1] = 0} -- or just {0}
    step:       Define the increment/decrement step per click. Defaults to 1.
    keyword:    Default keyword to be passed to the icon-object when creating images.
    updateCallback:     Function called when the value/dataref has changed independently of 
                        item visibility. Defaults to nil.
    pressedCallback:    Function called when a button is pressed. Defaults to 
                        defaultPressedCallback(...).
    releaseCallback:    Function called when a button is released. Defaults to 
                        defaultReleaseCallback(...).
--]]
function KeyType.new(icon, opts) 
    local self = BaseType.new(icon, opts)
    if opts == nil then 
        opts = {link2bus = true}
    else
        if opts.link2bus == nil then opts.link2bus = true end
    end
    setmetatable(self,KeyType)
    return self
end

--[[ KeyType:createInstance(...)
  Create a instance of this type.
dataref:    Dataref linked to this instance. This should usually be a string 
            (single dataref) but may also be a table of strings (multiple datarefs)
            if you are using custom callback functions.
override:   Optional table to override properties of the type definition for this
            specific instance, e.g. if you want to use a different maxval for 
            this instance only.
--]]
function KeyType:createInstance(dataref,override)
	local inst = BaseInstance.new(self,dataref,override)
    setCallback("updateCallback",  inst, self, nil)
    setCallback("pressedCallback", inst, self, defaultPressedCallback)
    setCallback("releaseCallback", inst, self, defaultReleaseCallback)
	return inst
end

--[[ SWITCH TYPE ************************************************************************
SwitchType is the class to create all sorts of switches: (stateful) pushbuttons, toggle switches,
rotary switches, potentiometers, handles, etc. 
--]]
SwitchType = {}
SwitchType.__index = SwitchType

--[[ SwitchType.new(...)
  Create the type object.
icon:       Icon to define the image(s) of the switch as well as the button location(s) and dimensions. 
            Note: If the icon contains only a single image for a non-rotary switches (angle = 0), the 
            image will be shown in the high/pressed state and hidden in the low/depressed state.
opts:       Table of options:
    maxval:     Highest valid value. Defaults to 1.
    minval:     Lowest valid value. Defaults to 0.
    center:     The value that matches the image without rotation. Defaults to 
                (minval+maxval)/2. Not relevant for multi-image switches.
    cycle:      Defines whether the switch is cyclic. Note that in that case, maxval will not be 
                reached but instead, the value will be set to minval, so set it to the highest
                legitimate value + 1. 
    momentary:  Defines momentary positions and where the switch will move to once the 
                control is released. Default to nil (no momentary positions). Expects a
                table containing the momentary position(s) as key(s) and the positions to
                which the control moves as  value. 
                Example - Magneto/Starter with values 0..4, 4 being start: 
                    {[4] = 3} -- jump to 3 if the switch is released on 4 
    step:       Defines the increment/decrement step per click. Defaults to 1.
    angle:      Set the angle of rotation per click. The value is automatically converted 
                to "per 1" (angle = angle/step).  Not relevant for multi-image switches.
    interval:   Used for switches with many positions (like encoders or potentiometers) 
                to define the interval (in ms) in which the switch is moved while the 
                button is held down. Defaults to 0 (no continues changes).
    tics:       Used in conjunction with 'interval' and 'factor' to create coarse and fine 
                control. Defines the number of regular 'tics' before the rate of change will
                be increased. Defaults to 0 (single speed).
                Ignored on controls that trigger commands instead of datarefs.
    factor:     Used in conjunction with 'interval' and 'tics'. Defines the factor of the 
                speedup. Defaults to 5.
                Ignored on controls that trigger commands instead of datarefs.
    keyword:    Default keyword to be passed to the icon-object when creating images.
    dial:       Enable the touch gesture/scroll wheel support. Defaults to true if angle is non-zero. 
                Ignored if CLASSIC_BUTTONS is set to true.
    updateCallback:     Function called when the value/dataref has changed independently of 
                        item visibility. Defaults todefaultUpdateCallbackSelect(...) or 
                        defaultUpdateCallbackRotate(...) depending on angle.
    pressedCallback:    Function called when a button is pressed. Defaults to 
                        defaultPressedCallback(...).
    releaseCallback:    Function called when a button is released. Defaults to 
                        defaultReleaseCallback(...).

    Example: A temperature dial that is supposed go from -1 to 1, with a rotation from -135° (-1) 
    to 135° (1), 270° full travel with 11 positions: Minval will be -1 and maxval 1, step will 
    be 0.2 (10 steps to change the dataref by 2), angle will be 27 and center is 0.
--]]
function SwitchType.new(icon, opts)
    local self = BaseType.new(icon, opts)
    setmetatable(self,SwitchType)
    return self
end

--[[ SwitchType:createInstance(...)
  Create a instance of this type.
dataref:    Dataref linked to this instance. This should usually be a string 
            (single dataref) but may also be a table of strings (multiple datarefs)
            if you are using custom callback functions.
override:   Optional table to override properties of the type definition for this
            specific instance, e.g. if you want to use a different maxval for 
            this instance only.
--]]
function SwitchType:createInstance(dataref,override)
	local inst = BaseInstance.new(self,dataref,override)
    setCallback("updateCallback",  inst, self, (self.angle == 0 and defaultUpdateCallbackSelect or defaultUpdateCallbackRotate))
    setCallback("pressedCallback", inst, self, defaultPressedCallback)
    setCallback("releaseCallback", inst, self, defaultReleaseCallback)
    if inst.updateCallback == nil then
        inst.updateCallback  = self.updateCallback
    end
	return inst
end

--[[ ENCODER TYPE ************************************************************************
EncoderType is the class to create encoders and other switches that aren't hard-linked, 
so turning the knob is still possible even tough the dataref might already be at it's limit.
--]]
EncoderType = {}
EncoderType.__index = EncoderType
--[[ EncoderType.new(...)
  Create the type object.
icon:       Icon to define the image(s) of the encoder as well as the button location(s) and dimensions. 
            Note: If the icon contains only a single image for a non-rotary switches (angle = 0), the 
            image will be shown in the high/pressed state and hidden in the low/depressed state.
opts:       Table of options:
    maxval:     Highest valid value. Defaults to 360. For encoders that are linked to commands, this 
                value is only relevant for the rotation of the image.
    minval:     Lowest valid value. Defaults to 0. For encoders that are linked to commands, this 
                value is only relevant for the rotation of the image.
    center:     The value that matches the image without rotation. Defaults to 
                (minval+maxval)/2. Not relevant for multi-image switches.
    cycle:      Defines whether the dataref cycles! Note that in 
                that case, maxval (e.g. 360) will not be reached but instead, the value 
                will be set to minval (e.g. 0). Defaults to true.
    digit:      Change the given digit only. Defaults to nil (change whole dataref)!
    step:       Defines the increment/decrement step per click. Defaults to 1.
    angle:      Set the angle of rotation per click. The value is automatically converted 
                to "per 1" (angle = angle/step).  Not relevant for multi-image encoders (e.g. VS wheel).
    interval:   Used for switches with many positions (like encoders or potentiometers) 
                to define the interval (in ms) in which the switch is moved while the 
                button is held down. Defaults to 0 (no continues changes).
    tics:       Used in conjunction with 'interval' and 'factor' to create coarse and fine 
                control. Defines the number of regular 'tics' before the rate of change will
                be increased. Defaults to 0 (single speed).
                Ignored on controls that trigger commands instead of datarefs.
    factor:     Used in conjunction with 'interval' and 'tics'. Defines the factor of the 
                speedup. Defaults to 5.
                Ignored on controls that trigger commands instead of datarefs.
    keyword:    Default keyword to be passed to the icon-object when creating images.
    dial:       Enable the touch gesture/scroll wheel support. Defaults to true. 
                Ignored if CLASSIC_BUTTONS is set to true.
    updateCallback:     Function called when the value/dataref has changed independently of 
                        item visibility. Defaults to defaultUpdateCallbackSelect(...) or 
                        defaultUpdateCallbackRotate(...) depending on angle.
    pressedCallback:    Function called when a button is pressed. Defaults to 
                        defaultPressedCallback(...).
    releaseCallback:    Function called when a button is released. Defaults to 
                        defaultReleaseCallback(...).

    Example: A hdg dial should go from -1 to 1, with a rotation from -135° (-1) to 135° (1), 270° full travel 
    and 11 positions. Minval will be -1 and maxval 1, step will be 0.2 (10 steps to change the dataref by 2), angle will 
    be 27 and center is 0.
--]]
function EncoderType.new(icon, opts)
    if opts.linked == nil then opts.linked = false end
    if opts.maxval == nil then opts.maxval = 360 end
    if opts.cycle  == nil then opts.cycle  = true end
    if opts.center == nil then opts.center = 0 end
    if opts.dial   ~= nil then opts.dial   = true end
    if opts.link2bus == nil then opts.link2bus = true end
    local self = BaseType.new(icon, opts)
    setmetatable(self,EncoderType)
    return self
end

--[[ EncoderType:createInstance(...)
  Create a instance of this type.
dataref:    Dataref linked to this instance. This should usually be a string 
            (single dataref) but may also be a table of strings (multiple datarefs)
            if you are using custom callback functions.
override:   Optional table to override properties of the type definition for this
            specific instance, e.g. if you want to use a different maxval for 
            this instance only.
--]]
function EncoderType:createInstance(dataref,override)
	local inst = BaseInstance.new(self,dataref,override)
    setCallback("updateCallback",  inst, self, (self.icon:count() > 1 and defaultUpdateCallbackSelect or defaultUpdateCallbackRotate))
    setCallback("pressedCallback", inst, self, defaultPressedCallback)
    setCallback("releaseCallback", inst, self, defaultReleaseCallback)
	return inst
end

--[[ GUARD TYPE ************************************************************************
GuardType is the class to create switch-guards.
--]]
GuardType = {}
GuardType.__index = GuardType

--[[ GuardType.new(...)
  Create the type object.
icon:       Icon to define the image(s) of the guard as well as the button location(s) and dimensions. 
opts:       Table of options:
    maxval:     	Highest valid value. Defaults to 1.
    minval:     	Lowest valid value. Defaults to 0.
    step:       	Defines the increment/decrement step per click. Defaults to 1.
    closepos:   	If not nil, the guard can only be closed if the guared instance is at the given position.
    setonclose: 	Value to set the guarded element to if the guard is closed.
    keyword:    	Default keyword to be passed to the icon-object when creating images.
    updateCallback:     Function called when the value/dataref has changed independently of 
                        item visibility. Defaults to defaultUpdateCallbackGuard(...).
    pressedCallback:    Function called when a button is pressed. Defaults to 
                        defaultPressedCallback(...).
    releaseCallback:    Function called when a button is released. Defaults to 
                        defaultReleaseCallback(...).
--]]
function GuardType.new(icon, opts)
    local self = SwitchType.new(icon, opts)
    setmetatable(self,GuardType)
    return self
end

--[[ GuardType:createInstance(...)
  Create a instance of this type.
dataref:    Dataref linked to this instance. This should usually be a string 
            (single dataref) but may also be a table of strings (multiple datarefs)
            if you are using custom callback functions.
guardedInst: Instance(s) that is protected by the guard. May either be a instance-
            object or a table of multiple instance objects. May even be nil if the
            guarded instance has not be created yet.
override:   Optional table to override properties of the type definition for this
            specific instance, e.g. if you want to use a different maxval for 
            this instance only.
--]]
function GuardType:createInstance(dataref,guardedInst,override)
	local inst = BaseInstance.new(self,dataref,override)
	if guardedInst ~= nil then
		inst:addGuardedInst(guardedInst)
    end
    setCallback("updateCallback",  inst, self, defaultUpdateCallbackGuard)
    setCallback("pressedCallback", inst, self, defaultPressedCallback)
    setCallback("releaseCallback", inst, self, defaultReleaseCallback)
	inst.updateCallback(inst)
	return inst
end

--[[ PBA TYPE ************************************************************************
PBAType is the class to create PBAs (push button annunciators), aka Korry switches.
Basically joins a SwitchType and a LEDType. 
--]]
PBAType = {}
PBAType.__index = PBAType

--[[ PBAType.new(...)
  Create the type object.
icon:       Icon to define the image(s) of the switch as well as the button location(s) and dimensions. 
            Note: If the icon contains only a single image for a non-rotary switches (angle = 0), the 
            image will be shown in the high/pressed state and hidden in the low/depressed state.
leddef:     LEDType object for the built in annunciators. 
ledoffset:  Vertical spacing of annunciators if PBA contains multiple annunciators. Defaults to 
            LED-icon-height * 1.2.
opts:       Table of options (for the button):
    maxval:     Highest valid value. Defaults to 1.
    minval:     Lowest valid value. Defaults to 0.
    momentary:  Defines momentary positions and where the switch will move to once the 
                control is released. Default to nil (no momentary positions). Expects a
                table containing the momentary position(s) as key(s) and the positions to
                which the control moves as  value. 
                Example - Simple 0/1 pushbutton, setting 1 while pushed and 0 when released: 
                    {[1] = 0} -- or just {0}
    step:       Defines the increment/decrement step per click. Defaults to 1.
    keyword:    Default keyword for the switch-type.
    updateCallback:     Function called when the value/dataref has changed independently of 
                        item visibility. Defaults to Defaults to defaultUpdateCallbackSelect(...) or 
                        defaultUpdateCallbackRotate(...) depending on angle.
    pressedCallback:    Function called when a button is pressed. Defaults to 
                        defaultPressedCallback(...).
    releaseCallback:    Function called when a button is released. Defaults to 
                        defaultReleaseCallback(...).
--]]
function PBAType.new(icon, leddef, opts, ledoffset)
	if ledoffset == nil then ledoffset = leddef.icon.height * 1.2 end
	local btndef = SwitchType.new(icon, opts)
	local self = {btndef = btndef, leddef = leddef, ledoffset = ledoffset}
    setmetatable(self,PBAType)
    return self
end

--[[ PBAType:createInstance(...)
  Create a instance of this type. All arguments are tables, the first element being passed 
  to the button and the following N arguments being passed to N LEDs.
datarefs:   Datarefs linked to this instance. This should usually be a string 
            (single dataref) but may also be a table of strings (multiple datarefs)
            if you are using custom callback functions.
overrides:  Optional tables to override properties of the type definition for this
            specific instance, e.g. if you want to use a different maxval for 
            this instance only.
--]]
function PBAType:createInstance(datarefs,overrides)
    return PBAInstance.new(self,datarefs,overrides)
end

--[[ PBA INSTANCE ************************************************************************
Custom instance object for PBAs. This is basically just a collection of one BaseInstance
for the button and N BaseInstances for the annunciators.
--]]
PBAInstance = {}
PBAInstance.__index = PBAInstance

--[[ PBAInstance.new(...)
  Create the object.
def:        Type-object that is creating this instance.
datarefs:   Datarefs for button and leds.
overrides:  Optional tables to override properties of the type-object, e.g. for the LED keywords.
--]]
function PBAInstance.new(def,datarefs,overrides)
    
	if overrides == nil then overrides = {} end
	local items = {}
	for k,v in pairs(datarefs) do
        if k == 1 then
			items[k] = def.btndef:createInstance(datarefs[k],overrides[k])
		else 
            items[k] = def.leddef:createInstance(datarefs[k],overrides[k])
        end
    end

	local self = {def = def, items = items, isvisible = vis}
	self.ledoffset = (#datarefs > 2 and def.ledoffset or 0)
	
	setmetatable(self,PBAInstance)
	return self
end

--[[ PBAInstance:show(...)
  Call show(...) on all contained BaseInstances.
--]]
function PBAInstance:show(id, isvisible)
	for k,v in pairs(self.items) do
		v:show(id, isvisible)
	end
end

--[[ PBAInstance:create(...)
  Call create(...) on all contained BaseInstances.
--]]
function PBAInstance:createVisuals(page,x,y,zoom)
	local yo = 0
	for k,v in pairs(self.items) do
		if k > 1 then yo = self.ledoffset * zoom * (math.floor(k*.5)-.5) * ((k % 2) == 0 and 1 or -1) end
		v:createVisuals(page,x,y+yo,zoom)
	end
end

--[[ PBAInstance:create(...)
  Call create(...) on all contained BaseInstances.
--]]
function PBAInstance:createControls(page,x,y,zoom)
	self.items[1]:createControls(page,x,y,zoom)
end

--[[ PBAInstance:lock(...)
  Disable element.
--]]
function PBAInstance:lock(l) 
    self.items[1]:lock(l)
end

--[[ PBAInstance:power(...)
  Power the element.
--]]
function PBAInstance:power(p)
    return self.items[1]:power(p)
end

--[[ PBAInstance:getValue(...)
  Get button value.
--]]
function PBAInstance:getValue() 
    return self.items[1]:getValue()
end

--[[ PBAInstance:update(...)
  Update button value.
--]]
function PBAInstance:update(...) 
    return self.items[1]:update(...)
end

--[[ PANEL TYPE ************************************************************************
As with switches we create a Type-object for panels first so we don't have to duplicate
all common properties on every panel we create.
--]]
PanelType = {}
PanelType.__index = PanelType
--[[ PanelType.new(...)
  Create the object.
file:       Filename for the panel type, may contain %% as placeholder for later replacement for the specific panels. 
doButtons:  Define if the elements on the default pane will have controls (true) or will be display-only versions (false).
--]]
function PanelType.new(file, imgzoom, lighttype)
	if imgzoom == nil then imgzoom = 1 end
	local self = { file = file, imgzoom = imgzoom, default = { zoom = 1 }}
	setmetatable(self,PanelType)
	return self
end

--[[ PanelType:addZoomedPane(...)
  Add a zoomed pane to the panel type.
zoom:       XXXX
doButtons:  Define if the elements on this pane will have controls (true) or will be display-only versions (false).
--]]
function PanelType:addZoomedPane(zoom)
	self.zoomed = { zoom = zoom }
	return self
end

--[[ PanelType:createInstance(...)
  Create a panel instance.
name:   Name to be used as keyword for file selection.
x/y:    Position of panel. Note that the values are the position of the upper left corner, 
        and not (like for switches) the position of the center.
--]]
function PanelType:createInstance(page,name,x,y)
	return Panel.new(self,page,name,x,y)
end

--[[ PANEL ************************************************************************
The instance of a panel type.
--]]
Panel = {}
Panel.__index = Panel

--[[ Panel.new(...) 
  Create the object.
def:    Parent PanelType.
name:   Name to be used as keyword for file selection.
x/y:    Position of panel. If <= 0, the values are inverted and interpreted as position of the upper left corner, 
        otherwise the position will be interpreted as position of the center of the panel.
width:  Width of panle.
height: Height of panel.
--]]
function Panel.new(def,page,name,x,y,lighttype)
    if lighttype == nil then lighttype = DEFAULT_LIGHTING_TYPE end
	local file = string.gsub(def.file, "%%%%", name)
	local resinf = resource_info(file .. ".png")
	if resinf == nil then
		return nil
	end
	
	local self = { name = name, def = def, page = page, file = file, 
				   rect = Rectangle.new(x, y, resinf.WIDTH * def.imgzoom, resinf.HEIGHT * def.imgzoom), 
				   items = {}, lightingType = lighttype}
    setmetatable(self,Panel)

    local pb = self.page.rect
    local dd = self.def.default
	local zd = self.def.zoomed
	local di = { x = pb.x + self.rect.x, y = pb.y + self.rect.y, 
				 width = self.rect.width, height = self.rect.height, zoom = dd.zoom, page = page}
	self.default = di
	
	if zd ~= nil then
		local zi = {width = di.width * zd.zoom, height = di.height * zd.zoom, zoom = zd.zoom}
		zi.page = PageStub.new(page.id .. "/" .. self.name .. "/ZOOMED", panel.lightingType, self.page.rect)
        zi.x = di.x + math.floor(di.width*.5 - zi.width*.5)
        zi.y = di.y + math.floor(di.height*.5 - zi.height*.5)
		if zi.x < pb.x then zi.x = pb.x elseif zi.x + zi.width  > pb.width  then zi.x = pb.width  - zi.width  end
		if zi.y < pb.y then zi.y = pb.y elseif zi.y + zi.height > pb.height then zi.y = pb.height - zi.height end
		self.zoomed = zi
	end
	
	page:add(self)
	
    return self
end

--[[ Panel:add(...) 
  Add an item (switch, led, ...) to the panel.
x/y:    Relative position on the panel.
item:   Item to add.
--]]
function Panel:add(x,y,item)
    table.insert(self.items, {x=x,y=y,item=item})
    return item;
end

--[[ Panel:last(...) 
  Retrieve a previously added element, e.g. if you didn't store it in a local variable. 
  Useful when creating switch guards:
    panel:add(x, y, MySwitch:createInstance(...))
    panel:add(x, y, MyGuard:createInstance(..., panel:last(), ...)
elem:   Position of element to retrieve, 1 = last element, 2 = 2nd last element ...
        When nil, the last element will be retrieved.
--]]
function Panel:last(elem) 
	return self.items[#self.items - (elem == nil and 1 or elem) + 1].item
end

--[[ Panel:create(...) 
  Create panel and items for the given pane.
id:     ID of the pane to be created.
--]]
function Panel:create(zoomed)
	print("PANEL(" .. self.name .. "):create(" .. tostring(zoomed) .. ")")
	local pane = self.default
	local page = self.page
	if zoomed then
		if self.zoomed == nil then return end
		pane = self.zoomed
		page = pane.page
		page:addElem(button_add(EMPTY, EMPTY, page.rect.x, page.rect.y, page.rect.width, page.rect.height, function() page:show(false) end, nil))
		table.insert(self.page.zoomed, page)
	end
	
	if self.file ~= nil then
		pane.images = ImageInstance.new(page, self.lightingType, pane.x, pane.y, pane.width, pane.height, {self.file})
	end
	for k,v in pairs(self.items) do
        v.item:createVisuals(page, pane.x + v.x * pane.zoom, pane.y + v.y * pane.zoom, pane.zoom)
    end
    if zoomed or self.zoomed == nil then
		-- create buttons:
        for k,v in pairs(self.items) do
            v.item:createControls(page, pane.x + v.x * pane.zoom, pane.y + v.y * pane.zoom, pane.zoom)
        end
	else
        -- create zoom in control:
		page:addElem(button_add(EMPTY, EMPTY, pane.x, pane.y, pane.width, pane.height, function() self.zoomed.page:show(true) end,  nil))
    end
end

--[[ PAGE  ************************************************************************
Page object to be used for multi-page layouts.
--]]
Page = {}
Page.__index = Page

--[[ Page.new(...) 
  Create the object.
file:           Optional filename for a background image. May be nil.
startupVisible: Show the page on startup (true) or hide it (false).
--]]
function Page.new(id, file, lighttype, rect)
    if lighttype == nil then lighttype = DEFAULT_LIGHTING_TYPE end
	local self = { id = id, 
                   file = file, 
                   visible = false,
                   rect    = rect, 
                   panels  = {},
				   zoomed  = {},
				   group   = nil,
				   lightingType = lighttype}
	setmetatable(self,Page)
	if self.rect == nil then
		self.rect = Rectangle.new(0, 0, WIDTH, HEIGHT)
	end
	return self
end

--[[ Page:add(...) 
  Add a panel to the page.
panel:  Panel to add.
--]]
function Page:add(panel)
	table.insert(self.panels, panel)
	return panel
end

--[[ Page:deploy(...) 
  Create all panes of all panels on the page.
--]]
function Page:deploy()
    local ff = (self.file == nil and EMPTY or self.file~= nil)
	self.image = ImageInstance.new(self, self.lightingType, self.rect.x, self.rect.y, self.rect.width, self.rect.height, {self.file}, nil)
	
	for k,v in pairs(self.panels) do
        v:create(false)
    end
	for k,v in pairs(self.panels) do
        v:create(true)
    end
	self:show(false)
    
	--local dr = IInt("PAGES/"..self.id.."_SHOW")
	--dr:subscribe(self)
    local ref = "PAGES/" .. self.id .. "_SHOW"
    local id = am_variable_create(ref, "INT", 0)
    am_variable_subscribe(ref, "INT", function(val) self:show(val > 0) end)
end

--[[ Page:show(...) 
  Show or hide the page.
isvisible:    Show the page (true) or hide it (false).
--]]
function Page:show(isvisible)
    if self.visible == isvisible then 
		if DEBUG then print(self.id .. ".show(" .. tostring(isvisible) .. ") : IGNORED") end 
		return 
	end
	if DEBUG then print(self.id .. ".show(" .. tostring(isvisible) .. ")") end
	self.visible = isvisible
    visible(self.group, isvisible)
	if not isvisible then
		for k,v in pairs(self.zoomed) do
			v.visible = false
			visible(v.group, false)
		end
	end
end

function Page:update(valpos, val)
	if valpos ~= nil then 
		self:show(val > 0)
	end
end

function Page:toggleElem(id, vis)
	if id == nil then return end
	if vis then
		if self.group == nil then
			self.group = group_add(id)
		else
			group_obj_add(self.group, id)
		end
	else
		if self.group ~= nil then
			group_obj_remove(self.group, id)
		end
	end
	visible(id, self.visible and vis)
end

function Page:addElem(id)
	self:toggleElem(id, true)
end

--[[ PAGE  ************************************************************************
  Minimal Page API for zoomed panels
--]]
PageStub = {}
PageStub.__index = PageStub

function PageStub.new(id, lighttype, rect)
	local self = { id = id, 
                   visible = false,
                   rect    = rect, 
				   group   = nil,
				   lightingType = lighttype}
	setmetatable(self,PageStub)
	return self
end

function PageStub:show(isvisible)
    if self.visible == isvisible then 
		if DEBUG then print(self.id .. ".show(" .. tostring(isvisible) .. ") : IGNORED") end 
		return 
	end
	if DEBUG then print(self.id .. ".show(" .. tostring(isvisible) .. ")") end
	self.visible = isvisible
    visible(self.group, isvisible)
end

function PageStub:toggleElem(id, visible)
	if id == nil then return end
	if visible then
		if self.group == nil then
			self.group = group_add(id)
		else
			group_obj_add(self.group, id)
		end
	else
		if self.group ~= nil then
			group_obj_remove(self.group, id)
		end
	end
	visible(id, self.visible and visible)
end

function PageStub:addElem(id)
	self:toggleElem(id, true)
end

--[[ DYNAMIC BUS ************************************************************************* 
The DynamicBus class is used to globally control pushbuttons, encoders, leds and segment displays
linked to an electric bus. If the bus is turn off, all linked leds and displays will stay off
and all linked buttons and encoders will stop working. 
You'll only need to use this class if your aircraft's internal logic doesn't to the calculations
itself. If you link your pushbuttons to commands that only work if the relevant bus is powered and 
your leds/displays to datarefs that only show something if the relevant bus is powered you can
ignore this class.
--]]
DynamicBus = {}
DynamicBus.__index = DynamicBus
--[[ DynamicBus.new(...)
  Create the icon object.
id:     ID of the global variable.
func:   Function that takes all dataref values as arguments and returns a bool value,
        -- Example 1: Power and avionics on:
        function(bat, gen, avionics) return (bat > 0 or gen > 0) and avionics > 0
        -- Example 2: Left bus is powered:
        function(bat, gen, tie) 
            return (bat[1] > 0 or gen[1] > 0) or (tie > 0 and (bat[2] > 0 or gen[2] > 0)
        end
...:    A list of datarefs
--]]
function DynamicBus.new(id, dataref, threshold)
    if dataref.isCommand ~= nil then dataref = {dataref} end
    if type(threshold) == "nil" then threshold = {1}
    elseif type(threshold) ~= "table" then threshold = {threshold} end
    
    local self = {
		id        = id,
        pwr       = nil,
        dataref   = dataref,
        threshold = threshold,
        values    = {},
        items     = {}
    }
    setmetatable(self,DynamicBus)
    
    -- link to datarefs:
    for k,v in pairs(dataref) do 
        if k > #self.threshold then
            self.threshold[k] = self.threshold[k-1]
        end
        v:subscribe(self, k)
    end
    return self
end

-- Update linked elements
function DynamicBus:update(index, val)
    if index ~= nil then
        self.values[index] = val
    end
    
    local newpwr = true;
    for k,v in pairs(self.values) do 
        newpwr = (newpwr and v >= self.threshold[k])
    end
    
    if index ~= nil and self.pwr == newpwr then return end -- force update on call w/o arguments
    self.pwr = newpwr
    
    if DEBUG then print("DynamicBus - " .. self.id .. ": " .. (self.pwr and "ON" or "OFF")) end
    for k,v in pairs(self.items) do
        v:power(self.pwr)
    end
end

-- Add Element that will be controlled by the DynamicBus
function DynamicBus:addItem(item)
    table.insert(self.items, item)
    return self
end

-- Add all elements of panel to the DynamicBus
function DynamicBus:addPanel(panel)
    for k,v in pairs(panel.items) do
        if v.item.link2bus then
            table.insert(self.items, v.item)
        end
    end
    return self
end

--[[ DATAREF ************************************************************************* 
The Dataref class is used to store all relevant properties of a dataref (name, type, index).
--]]
DataRef = {}
DataRef.__index = DataRef
--[[ DataRef.new(...)
  Create the icon object.
--]]
function DataRef.new(kind, name, datatype, index)
	if kind == KIND_IN then
		local r = INTERNAL_DATAREFS[name]
		if r ~= nil then return r end
	end
	
    local self = {
		kind     = kind,
        name     = name,
        id       = nil,
        datatype = datatype,
        index    = index
    }
	setmetatable(self,DataRef)

	if kind == KIND_IN then
		INTERNAL_DATAREFS[name] = self
		self.callbacks = {}
	end
	return self
end

function DataRef:isCommand()
    return false
end

function DataRef:write(val)
	if type(val) == "nil" then val = 0 end
	if DEBUG then print("---> " .. self.name .. (self.index ~= nil and ("["..self.index.."]") or "" ) .. " (" .. self.datatype .. ") = " .. val) end
	if self.kind == KIND_AM then
        if self.id == nil then
            self.id = am_variable_create(self.name, self.datatype, val)
        else
            am_variable_write(self.id,val)
        end
    elseif self.kind == KIND_XP then
		xpl_dataref_write(self.name,self.datatype,val,index)
    elseif self.kind == KIND_IN then
		self.value = val
		for k,v in pairs(self.callbacks) do
			v(val)
		end
	end
end

function DataRef:subscribe(obj, valuenum)
    local inst = {obj = obj}
    if self.index ~= nil then
        inst.update = function(val) 
			if DEBUG and not self.silent then print("<=== " .. self.name .. "[" .. self.index .. "] (" .. self.datatype .. ") = " .. tostring(val[self.index])) end
            inst.obj:update(valuenum, val[self.index]) 
        end
    else
        inst.update = function(val) 
            if DEBUG and not self.silent then print("<--- " .. self.name .. " (" .. self.datatype .. ") = " .. tostring(val)) end
			inst.obj:update(valuenum, val) 
        end
    end
	if self.kind == KIND_AM then
		am_variable_subscribe(self.name, self.datatype, inst.update)
    elseif self.kind == KIND_XP then
        xpl_dataref_subscribe(self.name, self.datatype, inst.update)
    elseif self.kind == KIND_IN then
		table.insert(self.callbacks, inst.update)
		if type(self.value) ~= "nil" then
			inst.update(self.value)
		end
    end
end

-- Helper functions:
function DRHelper(kind, name, basetype, index, maxindex)
    if index == nil then 
        return DataRef.new(kind, name, basetype)
    end
    if maxindex == nil then maxindex = index end
    return DataRef.new(kind, name, basetype .. "[" .. maxindex .. "]", index)
end

function XInt(name, index, maxindex)
    return DRHelper(KIND_XP, name, "INT", index, maxindex)
end
function XFlt(name, index, maxindex)
    return DRHelper(KIND_XP, name, "FLOAT", index, maxindex)
end
function XStr(name)
    return DataRef.new(KIND_XP, name, "STRING")
end
function XByt(name, size)
	return DataRef.new(KIND_XP, name, "BYTE[" .. size .. "]")
end

function AInt(name, index, maxindex)
    return DRHelper(KIND_AM, name, "INT", index, maxindex)
end
function AFlt(name, index, maxindex)
    return DRHelper(KIND_AM, name, "FLOAT", index, maxindex)
end
function AStr(name)
    return DataRef.new(KIND_AM, name, "STRING")
end
function AByt(name, size)
    return DataRef.new(KIND_AM, name, "BYTE[" .. size .. "]")
end

function IInt(name, index, maxindex)
    return DRHelper(KIND_IN, name, "INT", index, maxindex)
end
function IFlt(name, index, maxindex)
    return DRHelper(KIND_IN, name, "FLOAT", index, maxindex)
end
function IStr(name)
    return DataRef.new(KIND_IN, name, "STRING")
end

--[[ COMMAND ************************************************************************* 
The Dataref class is used to store all relevant properties of a command (pair) (up command, down command).
--]]
Command = {}
Command.__index = Command
--[[ Command.new(...)
  Create the icon object.
--]]
function Command.new(kind, up, down, callback_up, callback_down)
    local self = {
		kind     = kind,
        up       = up,
        down     = down,
		name     = up
    }
    setmetatable(self,Command)
    if callback_up ~= nil then
        if kind == KIND_AM then
            am_command_subscribe(up,callback_up)
            if callback_down ~= nil then
                am_command_subscribe(down,callback_down)
            end
        elseif kind == KIND_IN then
            INTERNAL_COMMANDS[up] = callback_up
            if callback_down ~= nil then
                INTERNAL_COMMANDS[down] = callback_down
            end
        end
    end
    return self
end

function Command:isCommand()
    return true
end

function Command:invoke(dir)
    local cmd = (dir > 0 and self.up or self.down)
    if cmd == nil then return end
    if DEBUG then print("===> " .. cmd .. " (" .. self.kind .. ")") end
    if self.kind == KIND_AM then
        am_command(cmd)
    elseif self.kind == KIND_XP then
        xpl_command(cmd)
    elseif self.kind == KIND_IN then
        INTERNAL_COMMANDS[cmd]()
    end
end

function Command:subscribe(func)
    if self.kind == KIND_AM then
        am_command_subscribe(self.name, func)
    end
end

function XCmd(up, down) 
    return Command.new(KIND_XP, up, down)
end
function ACmd(up, down, cb_up, cb_down)
    return Command.new(KIND_AM, up, down, cb_up, cb_down)
end
function ICmd(up, down, cb_up, cb_down)
    return Command.new(KIND_IN, up, down, cb_up, cb_down)
end

--[[ LOGIC ************************************************************************* 
The Logic class is used to create internal logics that the aircraft didn't supply,
e.g. to automatically change a dataref if another one changes.
--]]
Logic = {}
Logic.__index = Logic
--[[ Logic.new(...)
  Create the icon object.
datarefs:  Table of datarefs
logic:     Function implementing the logic
--]]
function Logic.new(datarefs, logic)
    local self  = {
		dataref = datarefs,
        logic   = logic,
        values  = {}
    }
    setmetatable(self,Logic)
    for k,v in pairs(datarefs) do
        self.values[k] = 0
    end
    -- must be done in separate loops or logic will be called before values are initialized:
    for k,v in pairs(datarefs) do
        v:subscribe(self, k)
    end
	self:logic()
    return self
end

function Logic:update(valpos, val)
    if self.values[valpos] ~= val then
        local old = self.values[valpos]
        self.values[valpos] = val
        self:logic(valpos, val, old)
    end
end

function Logic:write(valpos, val)
    if self.values[valpos] ~= val then
        print(">>> " .. self.dataref[valpos].name .. " := " .. tostring(val))
        self.values[valpos] = val
        self.dataref[valpos]:write(val)
    end
end
