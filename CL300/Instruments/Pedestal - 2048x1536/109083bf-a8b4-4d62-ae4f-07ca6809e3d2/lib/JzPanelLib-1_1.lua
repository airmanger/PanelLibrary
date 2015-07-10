-- NOTE: For a tutorial on how to use the library see http://forums.x-plane.org/index.php?showtopic=85916


--[[
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

- GaugeType:   Now supports custom calculations for non-linear gauges without defining a complete drawCallback-Function.

- LEDType:     Now supports custom calculations for complex multi dataref leds without defining a complete drawCallback-Function.
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

TYPE_TG = 1 -- Toggle/Push 
TYPE_DN = 2 -- Down/Decrease/Left
TYPE_UP = 3 -- Up/Increase/Right
TYPE_NO = 4 -- No action

WIDTH    = instrument_prop("PREF_WIDTH")
HEIGHT   = instrument_prop("PREF_HEIGHT")
DEBUG    = instrument_prop("DEVELOPMENT") -- enable logging, call own update()-function when changing a dataref

-- EMPTY: Transparent image to be used for the invisible buttons.
EMPTY = "EMPTY.png"
-- NOCURSER: You can use this variably to override all cursors with a single graphic
-- Note that you cannot use a completely transparent image as cursor, therefore use a 
-- grey pixel/rectangle with 1% opacity if you want a invisible cursor
NOCURSOR = nil
-- ALLOW_REVERSE: If this is set to true, the up/down button will move the switch in the 
-- opposite direction (down/up) if the switch is already at its end of its movement. 
ALLOW_REVERSE = false
-- CLASSIC_BUTTONS: If this is set to true, encoders and rotary switches will use the old button interface.
CLASSIC_BUTTONS = false

--[[ HELPER FUNCTIONS *********************************************************************** --]]
-- Helper function to show a single of multiple images:
function setImageVisibility(images, selected)
    if images == nil then return end
    for k,v in pairs(images) do
        if v ~= nil then visible(v,selected == k) end
    end
    images.selected = selected
	if selected ~= nil and selected > 0 then return images[selected] else return nil end
end

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
            return (val < threshold) and 1 or 0
        else
            return (val >= threshold) and 1 or 0
        end
    end
    if invert then
        for k = 1, #threshold do
            if val < threshold[k] then return k - 1 end
        end
        return #threshold
    else
        for k = #threshold, 1, -1 do
            if val >= threshold[k] then return k end
        end
        return 0
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
the image and optionally a Cursor-Set object to be used for this kind of control and 
up to three rectangles for the button locations (toggle, down, up). If a instance of 
a switch using an icon only has two valid positions (or down/up aren't defined) then 
a single toggle button is created. Otherwise separate down- and up-buttons are created. 
That way you can use a single icon to create both a two- and three-position toggle switch.

Usually you will only need to create the icon-objects. All other functions 
will be called internally by the extending classes (LED, Switch, etc.)
--]]
Icon = {}
Icon.__index = Icon

--[[ Icon.new(...)
  Create the icon object.
files:              Filename(s) of the image(s) either as a string or a table
                    of strings. May be nil if you need an icon-Object
					as invisible element
					The filenames may include the string %% which may 
                    later be changed against a keyword when instancing the icon.
                    If you have a file "LED RED.png" and a file "LED GREEN.png" you 
                    can use the filename "LED %%.png" to create a single icon object 
                    for both a red and green led. All extending classes (LED, Switch) 
                    support selecting the correct image by supplying a keyword as 
                    additional argument.
width/height:       icon/image width/height
cursorset:          Optional CursorSet-Object to be used with the buttons
cltoggle/down/up:   Optional Rectangle-Objects to describe the button areas of the icon
                    cltoggle defaults to a Rectangle spanning the whole icon size
                    cldown/clup default to nil (no down/up-buttons)
--]]
function Icon.new(files, width, height, cursorset, cltoggle, cldown, clup)
    local self = { width = width, height = height, cursor = cursorset, clickareas = {} }
    if files == nil then files = {} elseif type(files) == "string" then files = {files} end
    self.files = files 
    if cltoggle ~= nil then
        self.clickareas[TYPE_TG] = cltoggle
    else
        self.clickareas[TYPE_TG] = Rectangle.new(0,0,width,height)
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

--[[ Icon:createImage(...)
  Creates the image(s) at the given position. 
x/y:	            Center position
keyword:            Optional keyword to replace %% in the filename
zoom:               Optional zoom factor to rescale the images (e.g. for zoomed panels)
--]]
function Icon:createImage(x,y,keyword,zoom)
    if zoom == nil then zoom = 1 end
    x = x - math.floor(self.width * zoom * .5)
    y = y - math.floor(self.height * zoom * .5)
	
	if self.files == nil then
		return nil
	else
		imgs = {}
		for k,v in pairs(self.files) do
			if v ~= nil then
				if keyword ~= nil then v = string.gsub(v, "%%%%", keyword) end
                --if DEBUG then print("IMG: " .. v .. " (" .. x .. "/" .. y ..")") end
				imgs[k] = img_add(v, x, y, self.width * zoom, self.height * zoom)
				visible(imgs[k], false)
			else 
				imgs[k] = nil
			end
		end
		return imgs
	end
end

--[[ Icon:createButton(...) 
  Creates a button at the given position. 
x/y:	            Center position
btntype:            Type-Constant (TYPE_TG, TYPE_UP, TYPE_DN) to select the button to be created
clickcallback:      Callback-function for the click/press events of the button
releasecallback:    Optional callback-function for the depress event of the button
--]]
function Icon:createButton(x,y, zoom, btntype, clickcallback, releasecallback)
    a = self.clickareas[btntype]
    if a == nil then return nil end
    x = x + a.x*zoom - math.floor(a.width*zoom*.5)
    y = y + a.y*zoom - math.floor(a.height*zoom*.5)
    
    local width = (a.width > 0 and a.width or self.width)*zoom
    local height = (a.height > 0 and a.height or self.height)*zoom
    
    btn = button_add(EMPTY, EMPTY, x, y, width, height, clickcallback, releasecallback)
    if self.cursor ~= nil then  
        self.cursor:setCursor(btn, btntype)
    end
	return btn
end

--[[ Icon:createDial(...) 
  Creates a button at the given position. 
x/y:	            Center position
angle:              Angle of rotation for touch gesture
clickcallback:      Callback-function for the click/press events of the button
--]]
function Icon:createDial(x,y, zoom, angle, clickcallback)
    a = self.clickareas[TYPE_TG]
    if a == nil then return nil end
    x = x + a.x*zoom - math.floor(a.width*zoom*.5)
    y = y + a.y*zoom - math.floor(a.height*zoom*.5)
    
    local width = (a.width > 0 and a.width or self.width)*zoom
    local height = (a.height > 0 and a.height or self.height)*zoom
    
    dial = dial_add(EMPTY, x, y, width, height, clickcallback)
    touch_setting(dial, "ROTATE_TICK", angle)
    if self.cursor ~= nil then  
        self.cursor:setDialCursor(dial, TYPE_UP, TYPE_DN)
    end
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
function TextField.new(family, size, alignment, color, width, height)
    local self = { width = width, height = height, family = family, size = size, color = color, alignment = alignment }
    setmetatable(self,TextField)
    return self
end

--[[ TextField:count()
  For compatibility with Icon-interface.
--]]
function TextField:count()
	return 1
end

--[[ TextField:hasUpDown()
  For compatibility with Icon-interface.
--]]
function TextField:hasUpDown()
	return false
end

--[[ TextField:createImage(...)
  Creates the image(s) at the given position. 
x/y:	            Center position
keyword:            -Ignored-
zoom:               Optional zoom factor to rescale the images (e.g. for zoomed panels)
--]]
function TextField:createImage(x,y,keyword,zoom)
    if zoom == nil then zoom = 1 end
    x = x - math.floor(self.width * zoom * .5)
    y = y - math.floor(self.height * zoom * .5)
    return {txt_add(" ", "-fx-font-family:\"" .. self.family .. "\"; -fx-font-size:" .. math.floor(self.size * zoom) 
                    .. "px; -fx-fill: " .. self.color .. "; -fx-text-alignment: " .. self.alignment .. ";", 
                    x, y, self.width * zoom, self.height * zoom)}
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
		imgNum            = 1,
        def               = def,
		occurances        = {},
        dataref           = dataref, 
        index             = nil, 
        selected          = 0,
        values            = {}, 
        valueCount        = 0,
        linked            = true, -- Switch and dataref are linked (e.g. rotary switch, toggle switch)
        position          = 0,    -- Position of switch, can differ from the dataref value (e.g. encoders, unpowered pushbuttons)
        interval          = 0,
        tic               = 0,
        ispowered         = true,
		isdisabled        = false,
        keyword           = nil, 
		guardedInst       = nil,
		updateCallback    = nil,
        drawCallback      = nil,
        pressedCallback   = nil,
        releaseCallback   = nil,
        cursorCallback    = nil
    }    
    
    if #dataref > 0 and dataref[1] ~= nil then
        self.name    = dataref[1].name
        self.command = dataref[1]:isCommand()
    else
        self.name    = "-none-"
        self.command = false
    end
    for k,v in pairs(dataref) do
        table.insert(self.values, 0)
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
    
    -- override defaults:
    if type(override) == "table" then
        for k,v in pairs(override) do
            self[k] = v
        end
    end
    self.imgCount = self.icon:count()
    
    if self.step == nil then self.step = 0 end
    if self.step ~= 0 and self.maxval ~= nil and self.minval ~= nil then
        -- we use 1.001 to take care of rounding issues with steps < 1... we don't want 20.00001 values!   
        self.valueCount  = math.floor(1.00001 + (self.maxval - self.minval) / self.step)
    else
        self.valueCount = -1
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
    else
        for k,v in pairs(self.dataref) do 
            if v ~= nil then v:subscribe(self, k) end 
        end
    end
    
    return self
end	

--[[ BaseInstance:show(...)
  Toggle visibility of the instance.
id:         Name/ID of the pane of the instance (default, zoomed). 
            May be "*" for all panes.
isvisible:  Show (true) or hide (false) the instance.
--]]
function BaseInstance:show(id, isvisible)
	if (id == "*") then
		for k,v in pairs(self.occurances) do
			self:show(k, isvisible)
		end
		return
	end
	
	local occ = self.occurances[id]
	if occ == nil then
		return
	end
	
	-- might be called with visible nil by guarding instance
	if isvisible ~= nil then
		occ.isvisible = isvisible
	end
	-- display ----------------------------------------
	if self.drawCallback ~= nil then 
		if occ.isvisible then
			self.drawCallback(self)
		else
			setImageVisibility(occ.images,nil)
		end
	end
	-- manipulator ------------------------------------
	if self.pressedCallback ~= nil then 
		for k,v in pairs(occ.buttons) do
			visible(v, occ.isvisible)
		end
		if occ.isvisible and self.cursorCallback ~= nil then
			self.cursorCallback(self)
		end
	end
end

--[[ BaseInstance:create(...)
  Create/deploy the instance on a pane.
id:         Name/ID of the pane of the instance (default, zoomed). 
x/y/zoom:   Absolute position and zoom to be passed to the Icon for 
            image/button creation.
--]]
function BaseInstance:create(id,x,y,zoom,doButtons,doDisplay)
	
    local occ = self.occurances[id]
	if occ == nil then 
		occ = { buttons = {}, isvisible = false }
		self.occurances[id] = occ
	end
	
	if doButtons == nil then doButtons  = true end
	if doDisplay == nil then doDisplay = true end
	
	-- display ----------------------------------------
	if doDisplay and self.drawCallback ~= nil then 
		occ.images = self.icon:createImage(x,y,self.keyword,zoom)
	end
    -- manipulator ------------------------------------
    if doButtons and self.pressedCallback ~= nil then 
		local dirs
        if self.dial then
            dirs = {[TYPE_TG] = 2}
            local inst = {obj = self, impl = self.pressedCallback, release = self.releaseCallback}
            inst.implDial = function(dir) inst.impl(inst.obj, dir) end
            occ.buttons[TYPE_TG] = self.icon:createDial(x,y, zoom, self.angle, inst.implDial)
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
                -- create button
                occ.buttons[k] = self.icon:createButton(x, y, zoom, k, inst.pushed, inst.released)
            end
        end
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
    if self.updateCallback ~= nil then self.updateCallback(self) end
    if self.drawCallback   ~= nil then self.drawCallback(self)   end
    if self.cursorCallback ~= nil then self.cursorCallback(self) end
end

--[[ BaseInstance:getValue(...)
  Get the value of the element.
--]]
function BaseInstance:getValue()
    local v =  self.values[self.selected == 0 and 1 or self.selected]
    if v == nil then return 0 else return v end
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

--[[ BaseInstance:disable(...)
  Disable element, if it's mechanically blocked (e.g. protect by guard)
--]]
function BaseInstance:disable(disabled) 
    self.isdisabled = disabled
end

--[[ BaseInstance:disabled(...)
  Return if the the element is disabled.
--]]
function BaseInstance:disabled() 
	if self.isdisabled then return true end
    if self.guardedInst ~= nil and self.unlocked ~= nil then
        for k,v in pairs(self.guardedInst) do
            if v:getValue() ~= self.unlocked then return true end
        end
    end
    return false
end

--[[ BaseInstance:power(...)
  Enable or disable element, if it's not powered (dials will still turn but do nothing!)
--]]
function BaseInstance:power(powered) 
    self.ispowered = powered
end

--[[ BaseInstance:powered(...)
  Return if the the element is powered.
--]]
function BaseInstance:powered() 
	return self.ispowered
end

--[[ BaseInstance:sendValue(...)
  Send dataref change or command to the simulator.
val: Value for datarefs
dir: Direction for commands
--]]
function BaseInstance:sendValue(val, dir) 
    for k,v in pairs(self.dataref) do
        if self.selected == 0 or k == self.selected then 
            if v:isCommand() then
                v:invoke(dir)
            else
                v:write(val)
            end
        end
    end
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
    if self.angle    == nil then self.angle    = 0 else self.angle = self.angle / self.step end -- converted from per click to per 1
    if self.dial     == nil then self.dial     = (self.angle ~= 0) end
    if self.digit    ~= nil then self.cycle    = true end -- enforce cycling in single digit mode
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

CursorCallback-Functions are called by the update()-function if the used Icon has a 
matching CursorSet to change the cursors (e.g. setting the cursor to none if the switch
is at its limit).

The first argument is always the matching element-instance.
--]]

--[[ Default draw callback for static images

--]]
defaultDrawCallbackStatic = function(inst)
	for k,v in pairs(inst.occurances) do
		if v.isvisible then
			setImageVisibility(v.images,1)
		end
	end
end

--[[ Default draw callback for segment displays
If neither pattern nor custom is defined, the (first) value is simply set. 
If pattern is set, string.format will be applied with that pattern and the given values.
If factors is defined as a table, the values are multiplied with the factors.
If custom is present, the function will be called with the current values instead.
If the instance is not powered, an empty text is drawn.
--]]
defaultDrawCallbackSegment = function(inst)
	local str = "" 
    if inst:powered() then 
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
	for k,v in pairs(inst.occurances) do
		if v.isvisible then
            txt_set(setImageVisibility(v.images,inst.imgNum), str)
		end
	end
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
defaultDrawCallbackThreshold = function(inst)
	local sel
    if not inst:powered() then 
        sel = 0
    else
        if inst.custom ~= nil then
            sel = inst.custom(table.unpack(inst.values))
        elseif #inst.values == 1 then
            sel = checkThreshold(inst.values[1], inst.threshold, inst.inverted)
        else
            sel = 9999
            for i = 1, #inst.values do
                if inst.inverted then
                    sel = math.max(sel, checkThreshold(inst.values[i], inst.threshold[i], inst.inverted))
                else
                    sel = math.min(sel, checkThreshold(inst.values[i], inst.threshold[i], inst.inverted))
                end
            end
        end
    end
    if inst.imgCount > 1 then
        sel = sel + 1
    end
    for k,v in pairs(inst.occurances) do
		if v.isvisible then
			setImageVisibility(v.images,sel)
		end
	end
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
defaultDrawCallbackSelect = function(inst) 
    local sel = nil
    -- multi image switch style default:
    if inst.valueCount == inst.imgCount then
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
	for k,v in pairs(inst.occurances) do
		if v.isvisible then
			setImageVisibility(v.images,sel)
		end
	end
end

--[[ Default draw callback rotary switch/gauge-style objects
The image is rotated according to the minval, maxval, angle and center-properties.
If the instance has a custom function, it is called to calculate the correct angle of rotation.
--]]
defaultDrawCallbackRotate = function(inst)
    local rot
    if inst.custom ~= nil then
        rot = inst.custom(table.unpack(inst.values))
    elseif not inst.linked then  -- no capping:
        rot = (inst:getPosition() - inst.center) * inst.angle
    else 
        rot = (var_cap(inst:getPosition(),inst.minval,inst.maxval) - inst.center) * inst.angle
    end
    for k,v in pairs(inst.occurances) do
		if v.isvisible then
			-- we don't need to handle inverted since angle will already be negative!
			img_rotate(setImageVisibility(v.images,inst.imgNum), rot)
		end
	end
end

--[[ Default cursor callback 
Cursor callback considering switch limits, button inverting and cycling. 
--]]
defaultCursorCallback = function(inst) 
	if NOCURSOR or inst.icon.cursor == nil then return end
	for k,v in pairs(inst.occurances) do
		if v.isvisible then
			if not inst.cycle and (inst.icon.cursor:canInvert() or inst.icon.cursor:canDisable()) then
				for k,v in pairs(v.buttons) do
					curtype = k
					if inst:disabled() then
						curtype = TYPE_NO
					elseif curtype == TYPE_TG then
						if not inst.icon.cursor:hasToggle() then curtype = (inst:upperLimit() and TYPE_DN or TYPE_UP) end
					elseif curtype == TYPE_UP then 
						if inst:upperLimit()  then curtype = ((inst.interval > 0 or not ALLOW_REVERSE) and TYPE_NO or TYPE_DN) end
					elseif curtype == TYPE_DN then
						if inst:lowerLimit()  then curtype = ((inst.interval > 0 or not ALLOW_REVERSE) and TYPE_NO or TYPE_UP) end
					end
					inst.icon.cursor:setCursor(v, curtype)
				end
			end
		end
	end
end

--[[ Default pressed callback 
Pressed callback considering switch limits, button inverting and cycling.
dir is the selected direction of movement (1 = up, -1 = down, 0 = toggle)
--]]
defaultPressedCallback = function(inst, dir)
    if inst:disabled() then return end
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
        --if 
        if inst.interval == 0 and not inst.cycle and not inst.command and ALLOW_REVERSE then
            -- reverse direction at ends for non-interval switches:
            if val <= inst.minval then
                dir = math.abs(dir)
            elseif val >= inst.maxval then 
                dir = - math.abs(dir)
            end
        end
        -- coarse factor
        if inst.interval > 0 and inst.tics ~= nil and inst.tics > 0 then
            inst.tic = inst.tic + 1
            if inst.tic > inst.tics then
                dir = dir * inst.factor
            end
        end
        -- final calculation
        val = var_round(val + dir * inst.step,4)
        -- cycling/capping
        if inst.cycle then
            val = var_cycle(val, inst.minval, inst.maxval)
        else
            val = var_cap(val, inst.minval, inst.maxval)
        end
    end
    if inst.guardedInst ~= nil and inst.setonclose ~= nil and val < inst.maxval then
        for k,v in pairs(inst.guardedInst) do
            v:update(inst.setonclose)
        end
    end
    -- set position if not linked (encoders, command buttons)
    if inst.command then
        inst.position = val
    elseif not inst.linked then
        inst.position = inst:getPosition() + dir
    end
    if inst:powered() then
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
        if inst:powered() then
            inst:sendValue(val, val < inst:getPosition() and -1 or 1) -- convert to direction
        end
        if not inst.linked then
            inst.position = val
        end
        if DEBUG or not inst.linked then inst:update() end
    end
end
    
--[[ Default update callback  for guards
Update callback disabling the guarded element if the guard isn't at its maxval.
--]]
defaultGuardUpdateCallback = function(inst)
    for k,v in pairs(inst.guardedInst) do
        v:disable(not inst:upperLimit())
        v:show("*")
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
    setCallback("drawCallback", inst, self, defaultDrawCallbackStatic)
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
                icon contains a single ON image or two images (OFF/ON) or a table with N-1 
                threshold values if the icon contains N images (OFF/ON 1/ON 2/...).
                If multiple datarefs are linked, the thresholds are linked with MIN, so
                if the first dataref meets the 5th threshold and the second dataref meets 
                the 2nd, the image for the 2nd threshold (3rd image) will be selected.
    custom:     Function for extended threshold calculations. It will be called with all datarefs
                values as arguments and is expected to return a number of the selected image
                or nil if no image is to be shown.
    inverted:   Usually only used via override for single instances with a simple threshold: 
                Inverts the LED, so the ON image is shown when the threshold is not met!
                Defaults to false.
    keyword:    Default keyword to be passed to the icon-object when creating images.
    updateCallback:     Function called when the value/dataref has changed independently of 
                        item visibility. Defaults to nil.
    drawCallback:       Function called to draw the item (either when the value or the visibility 
                        has changed. Defaults to defaultDrawCallbackThreshold(...).
--]]
function LEDType.new(icon, opts)
    if opts == nil then opts = {} end
    if opts.threshold == nil then opts.threshold = 0.1 end
    if #icon.files < 3  then
        if type(opts.threshold) == "table" then opts.threshold = opts.threshold[1] end
    else
        if type(opts.threshold) ~= "table" then opts.threshold = {opts.threshold} end
        for i = #opts.threshold + 1, #icon.files - 1, 1 do opts.threshold[i] = opts.threshold[i-1] end 
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
    setCallback("drawCallback", inst, self, defaultDrawCallbackThreshold)
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
                        item visibility. Defaults to nil.
    drawCallback:       Function called to draw the item (either when the value or the visibility 
                        has changed. Defaults to defaultDrawCallbackRotate(...).
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
    setCallback("drawCallback", inst, self, defaultDrawCallbackRotate)
    setCallback("updateCallback",  inst, self, nil)
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
                        item visibility. Defaults to nil.
    drawCallback:       Function called to draw the item (either when the value or the visibility 
                        has changed. Defaults to defaultDrawCallbackSegment(...).
--]]
function SegmentType.new(textfield, opts)
    if opts == nil then
        opts = {icon = textfield}
    else
        opts.icon = textfield
    end

    local self = opts
    setmetatable(self,SegmentType)
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
    setCallback("drawCallback", inst, self, defaultDrawCallbackSegment)
    setCallback("updateCallback",  inst, self, nil)
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
    cursorCallback:     Function called when the value/dataref has changed to toggle button 
                        cursor depending on the switch position (if viable). Defaults to 
                        defaultCursorCallback(...).
    pressedCallback:    Function called when a button is pressed. Defaults to 
                        defaultPressedCallback(...).
    releaseCallback:    Function called when a button is released. Defaults to 
                        defaultReleaseCallback(...).
--]]
function KeyType.new(icon, opts) 
    local self = BaseType.new(icon, opts)
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
    setCallback("pressedCallback", inst, self, defaultPressedCallback)
    setCallback("releaseCallback", inst, self, defaultReleaseCallback)
    setCallback("cursorCallback",  inst, self, defaultCursorCallback)
    setCallback("updateCallback",  inst, self, nil)
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
                        item visibility. Defaults to nil.
    cursorCallback:     Function called when the value/dataref has changed to toggle button 
                        cursor depending on the switch position (if viable). Defaults to 
                        defaultCursorCallback(...).
    drawCallback:       Function called to draw the item (either when the value or the visibility 
                        has changed. Defaults to defaultDrawCallbackSelect(...) or 
                        defaultDrawCallbackRotate(...) depending on angle.
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
    setCallback("drawCallback",    inst, self, (self.angle == 0 and defaultDrawCallbackSelect or defaultDrawCallbackRotate))
    setCallback("pressedCallback", inst, self, defaultPressedCallback)
    setCallback("releaseCallback", inst, self, defaultReleaseCallback)
    setCallback("cursorCallback",  inst, self, defaultCursorCallback)
    setCallback("updateCallback",  inst, self, nil)
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
                        item visibility. Defaults to nil.
    cursorCallback:     Function called when the value/dataref has changed to toggle button 
                        cursor depending on the switch position (if viable). Defaults to 
                        defaultCursorCallback(...).
    drawCallback:       Function called to draw the item (either when the value or the visibility 
                        has changed. Defaults to defaultDrawCallbackSelect(...) or 
                        defaultDrawCallbackRotate(...) depending on angle.
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
    setCallback("drawCallback",    inst, self, (self.angle == 0 and defaultDrawCallbackSelect or defaultDrawCallbackRotate))
    setCallback("pressedCallback", inst, self, defaultPressedCallback)
    setCallback("releaseCallback", inst, self, defaultReleaseCallback)
    setCallback("cursorCallback",  inst, self, defaultCursorCallback)
    setCallback("updateCallback",  inst, self, nil)
    if inst.updateCallback == nil then
        inst.updateCallback  = self.updateCallback
    end
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
    maxval:     Highest valid value. Defaults to 1.
    minval:     Lowest valid value. Defaults to 0.
    step:       Defines the increment/decrement step per click. Defaults to 1.
    unlocked:   If not nil, the guard can only be closed if the guared instance is at the given unlocked position.
    setonclose: Value to set the guarded element to if the guard is closed.
    keyword:    Default keyword to be passed to the icon-object when creating images.
    updateCallback:     Function called when the value/dataref has changed independently of 
                        item visibility. Defaults to defaultGuardUpdateCallback(...).
    cursorCallback:     Function called when the value/dataref has changed to toggle button 
                        cursor depending on the switch position (if viable). Defaults to 
                        defaultCursorCallback(...).
    drawCallback:       Function called to draw the item (either when the value or the visibility 
                        has changed. Defaults to defaultDrawCallbackSelect(...).
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
	if guardedInst == nil then
        inst.guardedInst = {}
    elseif guardedInst.show ~= nil then
        inst.guardedInst = {guardedInst}
    else 
        inst.guardedInst = guardedInst
    end
    setCallback("drawCallback",    inst, self, defaultDrawCallbackSelect)
    setCallback("pressedCallback", inst, self, defaultPressedCallback)
    setCallback("releaseCallback", inst, self, defaultReleaseCallback)
    setCallback("cursorCallback",  inst, self, defaultCursorCallback)
    setCallback("updateCallback",  inst, self, defaultGuardUpdateCallback)
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
                        item visibility. Defaults to nil.
    cursorCallback:     Function called when the value/dataref has changed to toggle button 
                        cursor depending on the switch position (if viable). Defaults to 
                        defaultCursorCallback(...).
    drawCallback:       Function called to draw the item (either when the value or the visibility 
                        has changed. Defaults to defaultDrawCallbackSelect(...) or 
                        defaultDrawCallbackRotate(...) depending on angle.
    pressedCallback:    Function called when a button is pressed. Defaults to 
                        defaultPressedCallback(...).
    releaseCallback:    Function called when a button is released. Defaults to 
                        defaultReleaseCallback(...).
--]]
function PBAType.new(icon, leddef, ledoffset, opts)
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
function PBAInstance:create(id,x,y,zoom,doButtons,doDisplay)
	-- Create the images first, so the leds don't block the button:
	if doDisplay then
		local yo = 0
		for k,v in pairs(self.items) do
			if k > 1 then yo = self.ledoffset * zoom * (math.floor(k*.5)-.5) * ((k % 2) == 0 and 1 or -1) end
			v:create(id,x,y+yo,zoom,false,true)
		end
	end
	if doButtons then
		self.items[1]:create(id,x,y,zoom,true,false)
	end
end

--[[ PBAInstance:disable(...)
  Disable element.
--]]
function PBAInstance:disable(disabled) 
    self.items[1]:disable(disabled)
end

--[[ PBAInstance:disabled(...)
  Is the switch disabled?
--]]
function PBAInstance:disabled()
    return self.items[1]:disabled()
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

--[[ CURSOR SET ************************************************************************
A group of cursor images for creating switches. 
--]]
CursorSet = {}
CursorSet.__index = CursorSet

--[[ CursorSet.new(...)
  Creates the object.
toggle:     Cursor image if there is only a undirectional toggle operation
up:         Cursor image for the press/up/right/increase button
down:       Cursor image for the depress/down/left/decrease button
none:       Cursor image for disabled buttons (e.g. the left button if the swich is already on the leftmost position)
--]]
function CursorSet.new(toggle, down, up, none)
    local self = {}
	if NOCURSOR then
		self[TYPE_TG] = NOCURSOR
		self[TYPE_DN] = NOCURSOR
		self[TYPE_UP] = NOCURSOR
	else
		self[TYPE_TG] = toggle
		self[TYPE_DN] = down
		self[TYPE_UP] = up
		self[TYPE_NO] = none
	end
    setmetatable(self,CursorSet)
    return self
end

--[[ CursorSet:setCursor(...)
  Set the cursor of a button to the selected icon
btnid:        The ID of the button
cursortype:   Type of cursor to be set. Allowed values are TYPE_TG, TYPE_DN, TYPE_UP, TYPE_NO
--]]
function CursorSet:setCursor(btnid, cursortype)
	if btntype == TYPE_TG and self[TYPE_TG] == nil then
		btntype = TYPE_UP -- default to up, since the switch will start at 0
	end
    if self[cursortype] ~= nil then
        button_set_cursor(btnid, self[cursortype]) 
    end
end

--[[ CursorSet:setDialCursor(...)
  Set the cursor of a dial to the selected icon
dialid:     The ID of the dial
uptype:     Type of cursor to be set for the right (up) control. Allowed values are TYPE_TG, TYPE_DN, TYPE_UP, TYPE_NO
downtype:   Type of cursor to be set for the left (down) control. Allowed values are TYPE_TG, TYPE_DN, TYPE_UP, TYPE_NO
--]]
function CursorSet:setDialCursor(dialid, uptype, downtype)
	if uptype == TYPE_TG and self[TYPE_TG] == nil then
		uptype = TYPE_UP -- default to up, since the switch will start at 0
    elseif uptype == TYPE_UP and self[TYPE_UP] == nil then
        uptype = TYPE_TG
	end
	if downtype == TYPE_TG and self[TYPE_TG] == nil then
		downtype = TYPE_DN -- default to up, since the switch will start at 0
    elseif downtype == TYPE_DN and self[TYPE_DN] == nil then
        downtype = TYPE_TG
	end
    
    if self[uptype] ~= nil and self[downtype] ~= nil then
        dial_set_cursor(dialid, self[downtype], self[uptype]) 
    end
end

--[[ CursorSet:hasToggle(...)
  Returns whether the CursorSet contains a toggle-Cursor.
--]]
function CursorSet:hasToggle() 
	return self[TYPE_TG] ~= nil
end

--[[ CursorSet:canInvert(...)
  Returns whether the CursorSet has an up and down-Cursor, so swapping of cursor images is necessary.
--]]
function CursorSet:canInvert()
    return self[TYPE_UP] ~= nil and self[TYPE_DN] ~= nil
end

--[[ CursorSet:canDisable(...)
  Returns whether the CursorSet contains a none-Cursor, so setting a disabled cursor is necessary.
--]]
function CursorSet:canDisable()
    return self[TYPE_NO] ~= nil
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
function PanelType.new(file,doButtons)
	local self = { file = file, panes = { default = { zoom = 1, doButtons = doButtons } } }
	setmetatable(self,PanelType)
	return self
end

--[[ PanelType:addZoomedPane(...)
  Add a zoomed pane to the panel type.
zoom:       XXXX
doButtons:  Define if the elements on this pane will have controls (true) or will be display-only versions (false).
cursorSet:  CursorSet object for zoom-buttons.
fixedX/Y:   If set, the zoomed panel will not be created above the default panel but instead on a fixed location. 
            This can be used to have a complete and fully visible OHP on the upper half on the screen and a single 
            controllable panel on the lower half. In that case, no zoom-out buttons will be created.
--]]
function PanelType:addZoomedPane(zoom,doButtons,cursorSet,fixedX,fixedY)
	self.panes.zoomed = { zoom = zoom, doButtons = doButtons, cursor = cursorSet, fixedX = fixedX, fixedY = fixedY }
	self.ontop = (fixedX == nil and fixedY == nil) 
	return self
end

--[[ PanelType:addZoomedShadow(...)
  Create the object.
file:       Filename for the shadow file, may contain %% as placeholder for later replacement for the specific panels. 
offset:     Offset/border of the shadow file. 
--]]
function PanelType:addZoomedShadow(file, offset)
	local z = self.panes.zoomed
	if z == nil then return self end
	local o = z.zoom * offset
	z.shadow = { file = file, offset = o }
	return self
end

--[[ PanelType:createInstance(...)
  Create a panel instance.
name:   Name to be used as keyword for file selection.
x/y:    Position of panel. If <= 0, the values are inverted and interpreted as position of the upper left corner, 
        otherwise the position will be interpreted as position of the center of the panel.
width:  Width of panle.
height: Height of panel.
--]]
function PanelType:createInstance(name,x,y,width,height)
	return Panel.new(self, name,x,y,width,height)
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
function Panel.new(def,name,x,y,width,height)
	local self = { name = name, def = def, file = string.gsub(def.file, "%%%%", name), items = {}, panes = {} }
	local d = def.panes.default
	local z = def.panes.zoomed
	self.panes.default = { x = (x > 0 and (x - width * .5) or -x), 
	                       y = (y > 0 and (y - height * .5) or -y), 
						   width = width, height = height, zoom = d.zoom, doButtons = d.doButtons}
	
	if z ~= nil then
		local di = self.panes.default
		local zi = {width = di.width * z.zoom, height = di.height * z.zoom, zoom = z.zoom, doButtons = z.doButtons}
		
		if z.fixedX ~= nil then
			zi.x = z.fixedX - math.floor(zi.width*.5)
		else
			zi.x = di.x + math.floor(di.width*.5 - zi.width*.5)
		end
		if z.fixedY ~= nil then
			zi.y = z.fixedY - math.floor(zi.height*.5)
		else
			zi.y = di.y + math.floor(di.height*.5 - zi.height*.5)
		end
		if zi.x < 0 then zi.x = 0 elseif zi.x + zi.width > WIDTH then zi.x = WIDTH - zi.width end
		if zi.y < 0 then zi.y = 0 elseif zi.y + zi.height > HEIGHT then zi.y = HEIGHT - zi.height end

		self.panes.zoomed = zi
		
		if z.shadow ~= nil then
			local s = z.shadow; local o = s.offset
			zi.shadow = { file = string.gsub(s.file, "%%%%", name), x = zi.x-o, y = zi.y-o, height = zi.height+2*o, width = zi.width+2*o }
		end
	end

    setmetatable(self,Panel)
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

--[[ Panel:getPage(...) 
  Get the Page-object of the panel or a dummy page if no pages are used. Used for 
  zoomable panels with fixed locations for the zoomed pane.  
--]]
function Panel:getPage() 
	if self.page ~= nil then
		return self.page
	end
	if GLOBAL_PAGE == nil then
		GLOBAL_PAGE = {}
	end
	return GLOBAL_PAGE
end

--[[ Panel:create(...) 
  Create panel and items for the given pane.
id:     ID of the pane to be created.
--]]
function Panel:create(id)
	local pane = self.panes[id]
	if pane == nil then return end
    if id == "zoomed" and self.def.ontop then
		-- zoomed pane on top of default pane
		local inst = {obj = self }
		inst.zoom = function() inst.obj:show("default", true) inst.obj:show("zoomed", false) end
		self.panes.zoomed.button  = button_add(EMPTY, EMPTY, 0, 0, WIDTH, HEIGHT, inst.zoom, nil)
		if self.def.panes.zoomed.cursor ~= nil then self.def.panes.zoomed.cursor:setCursor(self.panes.zoomed.button, TYPE_TG) end
	end
	if pane.shadow ~= nil then
		local s = pane.shadow
		s.image = img_add(s.file, s.x, s.y, s.width, s.height)
	end
	
	if self.file ~= nil then
		pane.image = img_add(self.file, pane.x, pane.y, pane.width, pane.height)
	end
	
	for k,v in pairs(self.items) do
        v.item:create(id, pane.x + v.x * pane.zoom, pane.y + v.y * pane.zoom, pane.zoom, false, true)
    end
    if pane.doButtons then
        for k,v in pairs(self.items) do
            v.item:create(id, pane.x + v.x * pane.zoom, pane.y + v.y * pane.zoom, pane.zoom, true, false)
        end
    end
    
    if id == "default" and self.panes.zoomed ~= nil then
        -- create zoom in control:
        local inst = {obj = self }
		if self.def.ontop then 
			inst.zoom = function() inst.obj:show("default", false) inst.obj:show("zoomed", true) end
		else
			inst.zoom = function() 
				local pg = inst.obj:getPage()
				if pg.activePanel ~= nil then pg.activePanel:show("zoomed", false) end
				inst.obj:show("zoomed", true) 
				pg.activePanel = inst.obj
			end
		end
        local p = self.panes.default
        self.panes.default.button = button_add(EMPTY, EMPTY, p.x, p.y, p.width, p.height, inst.zoom,  nil)
		if self.def.panes.zoomed.cursor ~= nil then self.def.panes.zoomed.cursor:setCursor(self.panes.default.button, TYPE_TG) end
    end 
    if id == "zoomed" then self:show(id, false) end
end

--[[ Panel:new(...) 
  Show or hide the given pane. 
id:         ID of the pane to be shown/hidden.
isvisible:  Show the pane (true) or hide it (false).
--]]
function Panel:show(id, isvisible)
    if (id == "*") then
		for k,v in pairs(self.panes) do
			self:show(k, isvisible)
		end
		return
	end
	local p = self.panes[id]
	if p == nil then return end
	
	if p.shadow ~= nil then
		visible(p.shadow.image, isvisible)
	end
	if p.image ~= nil then
		visible(p.image, isvisible)
	end
	
	for k,v in pairs(self.items) do 
		v.item:show(id, isvisible)
    end
    
    if p.button ~= nil then
        visible(p.button, isvisible)
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
function Page.new(file, startupVisible)
    local self = { file = file, startupVisible = startupVisible, panels = {}, buttons = {} }
    setmetatable(self,Page)
    return self
end

--[[ Page:add(...) 
  Add a panel to the page.
panel:  Panel to add.
--]]
function Page:add(panel)
    table.insert(self.panels, panel)
	panel.page = self
    return panel
end

--[[ Page:deploy(...) 
  Create all panes of all panels on the page.
--]]
function Page:deploy()
    if self.file ~= nil then
        self.image = img_add_fullscreen(self.file)
    end
	for k,v in pairs(self.panels) do
        v:create("default")
    end
	for k,v in pairs(self.buttons) do
		local inst = {from = self, to = v.page}
		inst.func = function() 
			inst.from:show(false) 
			inst.to:show(true)
		end
		v.button = button_add(v.file, nil, v.rect.x - math.floor(v.rect.width*.5), v.rect.y - math.floor(v.rect.height*.5), v.rect.width, v.rect.height, inst.func, nil)
		if v.cursor ~= nil then v.cursor:setCursor(v.button, TYPE_TG) end
	end
	for k,v in pairs(self.panels) do
        v:create("zoomed")
    end
	self:show(self.startupVisible)
end

--[[ Page:show(...) 
  Show or hide the page.
isvisible:    Show the page (true) or hide it (false).
--]]
function Page:show(isvisible)
    if self.image ~= nil then
        visible(self.image, isvisible)
    end
    for k,v in pairs(self.buttons) do
        visible(v.button, isvisible)
    end
    local p = (isvisible and "default" or "*")
    for k,v in pairs(self.panels) do
        v:show(p, isvisible)
    end
	if isvisible and self.activePanel ~= nil then
		self.activePanel:show("zoomed", true)
	end
end

--[[ Page:addPageButton(...) 
  Add a button to change to another page.
file:       Filename for the image of the button.
page:       Page to be linked.
rect:       Position and size of the button
cursorset:  Optional CursorSet-object for the button. 
--]]
function Page:addPageButton(file,page,rect,cursorset)
	table.insert(self.buttons, {file = file, page = page, rect = rect, cursor = cursorset})
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
        if v.drawCallback ~= nil then
            v.drawCallback(v)
        end
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
        table.insert(self.items, v.item)
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
    local self = {
		kind     = kind,
        name     = name,
        id       = nil,
        datatype = datatype,
        index    = index
    }
    setmetatable(self,DataRef)
    return self
end

function DataRef:isCommand()
    return false
end

function DataRef:write(val)
    if DEBUG then print("---> " .. self.name .. (self.index ~= nil and ("["..self.index.."]") or "" ) .. " (" .. self.datatype .. ") = " .. val) end
    if self.kind == KIND_AM then
        if self.id == nil then
            self.id = am_variable_create(self.name, self.datatype, val)
        else
            am_variable_write(self.id,val)
        end
    elseif self.kind == KIND_XP then
        xpl_dataref_write(self.name,self.datatype,val,index)
    end
end

function DataRef:subscribe(obj, valuenum)
    local inst = {obj = obj}
    if self.index ~= nil then
        inst.update = function(val) 
            if DEBUG then print("<--- " .. self.name .. "[" .. self.index .. "] (" .. self.datatype .. ") = " .. val[self.index]) end
            inst.obj:update(valuenum, val[self.index]) 
        end
    else
        inst.update = function(val) 
            if DEBUG then print("<--- " .. self.name .. " (" .. self.datatype .. ") = " .. val) end
            inst.obj:update(valuenum, val) 
        end
    end
    if self.kind == KIND_AM then
        am_variable_subscribe(self.name, self.datatype, inst.update)
    elseif self.kind == KIND_XP then
        xpl_dataref_subscribe(self.name, self.datatype, inst.update)
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
function XData(name, index, maxindex)
    return DataRef.new(KIND_AM, name, "DATA")
end

function AInt(name, index, maxindex)
    return DRHelper(KIND_AM, name, "INT", index, maxindex)
end
function AFlt(name, index, maxindex)
    return DRHelper(KIND_AM, name, "FLOAT", index, maxindex)
end
function AData(name, index, maxindex)
    return DataRef.new(KIND_AM, name, "DATA")
end


--[[ COMMAND ************************************************************************* 
The Dataref class is used to store all relevant properties of a command (pair) (up command, down command).
--]]
Command = {}
Command.__index = Command
--[[ Command.new(...)
  Create the icon object.
--]]
function Command.new(kind, up, down)
    local self = {
		kind     = kind,
        up       = up,
        down     = down
    }
    setmetatable(self,Command)
    return self
end

function Command:isCommand()
    return true
end

function Command:invoke(dir)
    local cmd = (dir > 0 and self.up or self.down)
    if cmd == nil then return end
    if DEBUG then print("===> " .. cmd) end
    if self.kind == KIND_AM then
        am_command(cmd)
    elseif self.kind == KIND_XP then
        xpl_command(cmd)
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
function ACmd(up, down)
    return Command.new(KIND_AM, up, down)
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
