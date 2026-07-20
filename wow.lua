
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end

while not LocalPlayer.Character do
    LocalPlayer.CharacterAdded:Wait()
end

local Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({}, Signal)
    self._connections = {}
    return self
end

function Signal:Connect(callback)
    local connection = {
        Connected = true,
        Callback = callback,
        Disconnect = function(self)
            self.Connected = false
        end
    }
    table.insert(self._connections, connection)
    return connection
end

function Signal:Fire(...)
    for _, connection in ipairs(self._connections) do
        if connection.Connected then
            task.spawn(connection.Callback, ...)
        end
    end
end

function Signal:Wait()
    local thread = coroutine.running()
    local connection
    connection = self:Connect(function(...)
        connection:Disconnect()
        task.spawn(thread, ...)
    end)
    return coroutine.yield()
end

local bit32 = bit32 or bit or {}

if not bit32.band then
    bit32.band = function(a, b)
        local result = 0
        local bitval = 1
        while a > 0 and b > 0 do
            if a % 2 == 1 and b % 2 == 1 then
                result = result + bitval
            end
            bitval = bitval * 2
            a = math.floor(a / 2)
            b = math.floor(b / 2)
        end
        return result
    end
end

if not bit32.bor then
    bit32.bor = function(a, b)
        local result = 0
        local bitval = 1
        while a > 0 or b > 0 do
            if a % 2 == 1 or b % 2 == 1 then
                result = result + bitval
            end
            bitval = bitval * 2
            a = math.floor(a / 2)
            b = math.floor(b / 2)
        end
        return result
    end
end

if not bit32.bxor then
    bit32.bxor = function(a, b)
        local result = 0
        local bitval = 1
        while a > 0 or b > 0 do
            if (a % 2) ~= (b % 2) then
                result = result + bitval
            end
            bitval = bitval * 2
            a = math.floor(a / 2)
            b = math.floor(b / 2)
        end
        return result
    end
end

if not bit32.bnot then
    bit32.bnot = function(n)
        return (-1) - n
    end
end

if not bit32.lshift then
    bit32.lshift = function(a, b)
        return a * (2 ^ b)
    end
end

if not bit32.rshift then
    bit32.rshift = function(a, b)
        return math.floor(a / (2 ^ b))
    end
end

if not bit32.arshift then
    bit32.arshift = function(a, b)
        local result = math.floor(a / (2 ^ b))
        if a < 0 and b > 0 then
            result = result + (2 ^ (32 - b)) - 1
        end
        return result
    end
end

if not bit32.lrotate then
    bit32.lrotate = function(a, b)
        b = b % 32
        return bit32.bor(bit32.lshift(a, b), bit32.rshift(a, 32 - b))
    end
end

if not bit32.rrotate then
    bit32.rrotate = function(a, b)
        b = b % 32
        return bit32.bor(bit32.rshift(a, b), bit32.lshift(a, 32 - b))
    end
end

if not bit32.extract then
    bit32.extract = function(n, field, width)
        width = width or 1
        return bit32.band(bit32.rshift(n, field), (2 ^ width) - 1)
    end
end

if not bit32.replace then
    bit32.replace = function(n, v, field, width)
        width = width or 1
        local mask = (2 ^ width) - 1
        return bit32.bor(
            bit32.band(n, bit32.bnot(bit32.lshift(mask, field))),
            bit32.lshift(bit32.band(v, mask), field)
        )
    end
end

getgenv().bit = bit32

 setreadonly(getgenv().debug,false)
    getgenv().debug.traceback = getrenv().debug.traceback
    getgenv().debug.profilebegin = getrenv().debug.profilebegin
    getgenv().debug.profileend = getrenv().debug.profileend
    getgenv().debug.getmetatable = getgenv().getrawmetatable
    getgenv().debug.setmetatable = getgenv().setrawmetatable
    getgenv().debug.info = getrenv().debug.info
    getgenv().debug.loadmodule = getrenv().debug.loadmodule

    getgenv().syn_mouse1press = mouse1press
    getgenv().syn_mouse2click = mouse2click
    getgenv().syn_mousemoverel = movemouserel
    getgenv().syn_mouse2release = mouse2up
    getgenv().syn_mouse1release = mouse1up
    getgenv().syn_mouse2press = mouse2down
    getgenv().syn_mouse1click = mouse1click
    getgenv().syn_newcclosure = newcclosure
    getgenv().syn_clipboard_set = setclipboard
    getgenv().syn_clipboard_get = getclipboard
    getgenv().syn_islclosure = islclosure
    getgenv().syn_iscclosure = iscclosure
    getgenv().syn_getsenv = getsenv
    getgenv().syn_getscripts = getscripts
    getgenv().syn_getgenv = getgenv
    getgenv().syn_getinstances = getinstances
    getgenv().syn_getreg = getreg
    getgenv().syn_getrenv = getrenv
    getgenv().syn_getnilinstances = getnilinstances
    getgenv().syn_fireclickdetector = fireclickdetector
    getgenv().syn_getgc = getgc

local DrawingCache = {}
local DrawingObjects = {}

local Fonts = {
    [0] = Enum.Font.Arial,
    [1] = Enum.Font.BuilderSans,
    [2] = Enum.Font.Gotham,
    [3] = Enum.Font.RobotoMono
}

local function gethui()
    local success, result = pcall(function()
        return game:GetService("CoreGui")
    end)
    return success and result or game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
end
getgenv().gethui = gethui

local UI = Instance.new("ScreenGui")
UI.Name = "DrawingLib"
UI.DisplayOrder = 999999
UI.IgnoreGuiInset = true
UI.ResetOnSpawn = false
UI.Parent = gethui()

local Drawing = {
    Fonts = {
        UI = 0,
        System = 1,
        Plex = 2,
        Monospace = 3
    }
}

Drawing.new = function(drawingType)
    if type(drawingType) ~= "string" then
        error("Drawing.new: argument must be a string, got " .. type(drawingType), 2)
    end

    local validTypes = {
        Line = true,
        Square = true,
        Rectangle = true,
        Circle = true,
        Text = true,
        Image = true,
        Triangle = true,
        Quad = true
    }
    
    if not validTypes[drawingType] then
        error("Drawing.new: invalid drawing type '" .. drawingType .. "'", 2)
    end

    local drawingObj = Instance.new("Frame")
    drawingObj.BackgroundTransparency = 1
    drawingObj.BorderSizePixel = 0
    drawingObj.Size = UDim2.fromOffset(0, 0)
    drawingObj.Position = UDim2.fromOffset(0, 0)
    drawingObj.Parent = UI
    
    local properties = {
        Visible = true,
        Color = Color3.new(1, 1, 1),
        Transparency = 1,
        ZIndex = 1
    }
    
    local self = newproxy(true)
    local mt = getmetatable(self)
    
    local removed = false
    
    mt.__index = function(_, key)
        if key == "__OBJECT_EXISTS" then
            return not removed
        end
        return properties[key]
    end
    
    mt.__newindex = function(_, key, value)
        if removed then return end
        
        if key == "__OBJECT_EXISTS" then
            return
        end
        
        properties[key] = value
        
        if key == "Visible" then
            drawingObj.Visible = value
        elseif key == "Color" then
            drawingObj.BackgroundColor3 = value
        elseif key == "Transparency" then
            drawingObj.BackgroundTransparency = 1 - value
        elseif key == "ZIndex" then
            drawingObj.ZIndex = value
        end
    end
    
    mt.__tostring = function()
        return "Drawing"
    end
    
    mt.__metatable = "The metatable is locked"
    
    properties.Remove = function()
        if removed then return end
        
        removed = true
        
        if drawingObj and drawingObj.Parent then
            drawingObj:Destroy()
        end
        
        for i, obj in ipairs(DrawingCache) do
            if obj.proxy == self then
                table.remove(DrawingCache, i)
                break
            end
        end
        
        DrawingObjects[self] = nil
    end
    
    properties.Destroy = properties.Remove
    
    table.insert(DrawingCache, {proxy = self, instance = drawingObj})
    DrawingObjects[self] = true
    
    if drawingType == "Line" then
        drawingObj.AnchorPoint = Vector2.new(0.5, 0.5)
        
        properties.From = Vector2.zero
        properties.To = Vector2.zero
        properties.Thickness = 1
        
        local updateLine = function()
            if removed then return end
            
            local from = properties.From
            local to = properties.To
            local dx = to.X - from.X
            local dy = to.Y - from.Y
            local length = math.sqrt(dx * dx + dy * dy)
            
            drawingObj.Size = UDim2.fromOffset(length, properties.Thickness)
            drawingObj.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
            drawingObj.Rotation = math.deg(math.atan2(dy, dx))
            drawingObj.BackgroundTransparency = 1 - properties.Transparency
            drawingObj.BackgroundColor3 = properties.Color
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "From" or k == "To" or k == "Thickness" then
                updateLine()
            end
        end
        
    elseif drawingType == "Square" or drawingType == "Rectangle" then
        local stroke = Instance.new("UIStroke")
        stroke.Parent = drawingObj
        stroke.Thickness = 1
        stroke.Color = Color3.new(1, 1, 1)
        
        properties.Size = Vector2.zero
        properties.Position = Vector2.zero
        properties.Filled = false
        properties.Thickness = 1
        
        local updateSquare = function()
            if removed then return end
            
            drawingObj.Size = UDim2.fromOffset(properties.Size.X, properties.Size.Y)
            drawingObj.Position = UDim2.fromOffset(properties.Position.X, properties.Position.Y)
            
            if properties.Filled then
                drawingObj.BackgroundTransparency = 1 - properties.Transparency
                drawingObj.BackgroundColor3 = properties.Color
                stroke.Enabled = false
            else
                drawingObj.BackgroundTransparency = 1
                stroke.Enabled = true
                stroke.Color = properties.Color
                stroke.Thickness = properties.Thickness
                stroke.Transparency = 1 - properties.Transparency
            end
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "Size" or k == "Position" or k == "Filled" or k == "Thickness" or k == "Color" or k == "Transparency" then
                updateSquare()
            end
        end
        
    elseif drawingType == "Circle" then
        local stroke = Instance.new("UIStroke")
        stroke.Parent = drawingObj
        stroke.Thickness = 1
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = drawingObj
        
        properties.Radius = 50
        properties.Position = Vector2.zero
        properties.Filled = false
        properties.Thickness = 1
        properties.NumSides = 64
        
        local updateCircle = function()
            if removed then return end
            
            local diameter = properties.Radius * 2
            drawingObj.Size = UDim2.fromOffset(diameter, diameter)
            drawingObj.Position = UDim2.fromOffset(properties.Position.X - properties.Radius, properties.Position.Y - properties.Radius)
            
            if properties.Filled then
                drawingObj.BackgroundTransparency = 1 - properties.Transparency
                drawingObj.BackgroundColor3 = properties.Color
                stroke.Enabled = false
            else
                drawingObj.BackgroundTransparency = 1
                stroke.Enabled = true
                stroke.Color = properties.Color
                stroke.Thickness = properties.Thickness
                stroke.Transparency = 1 - properties.Transparency
            end
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "Radius" or k == "Position" or k == "Filled" or k == "Thickness" or k == "Color" or k == "Transparency" then
                updateCircle()
            end
        end
        
    elseif drawingType == "Triangle" then
        drawingObj:Destroy()
        
        drawingObj = Instance.new("Frame")
        drawingObj.BackgroundTransparency = 1
        drawingObj.BorderSizePixel = 0
        drawingObj.Size = UDim2.fromOffset(100, 100)
        drawingObj.Parent = UI
        
        local point1Frame = Instance.new("Frame")
        point1Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        point1Frame.BackgroundColor3 = Color3.new(1, 1, 1)
        point1Frame.BorderSizePixel = 0
        point1Frame.Parent = drawingObj
        
        local point2Frame = Instance.new("Frame")
        point2Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        point2Frame.BackgroundColor3 = Color3.new(1, 1, 1)
        point2Frame.BorderSizePixel = 0
        point2Frame.Parent = drawingObj
        
        local point3Frame = Instance.new("Frame")
        point3Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        point3Frame.BackgroundColor3 = Color3.new(1, 1, 1)
        point3Frame.BorderSizePixel = 0
        point3Frame.Parent = drawingObj
        
        properties.PointA = Vector2.zero
        properties.PointB = Vector2.new(50, 100)
        properties.PointC = Vector2.new(100, 0)
        properties.Filled = false
        properties.Thickness = 1
        
        local updateTriangle = function()
            if removed then return end
            
            local pA = properties.PointA
            local pB = properties.PointB
            local pC = properties.PointC
            
            local minX = math.min(pA.X, pB.X, pC.X)
            local minY = math.min(pA.Y, pB.Y, pC.Y)
            local maxX = math.max(pA.X, pB.X, pC.X)
            local maxY = math.max(pA.Y, pB.Y, pC.Y)
            
            drawingObj.Position = UDim2.fromOffset(minX, minY)
            drawingObj.Size = UDim2.fromOffset(maxX - minX, maxY - minY)
            
            local function drawLine(frame, p1, p2)
                local dx = p2.X - p1.X
                local dy = p2.Y - p1.Y
                local length = math.sqrt(dx * dx + dy * dy)
                
                frame.Size = UDim2.fromOffset(length, properties.Thickness)
                frame.Position = UDim2.fromOffset((p1.X + p2.X) / 2 - minX, (p1.Y + p2.Y) / 2 - minY)
                frame.Rotation = math.deg(math.atan2(dy, dx))
                frame.BackgroundColor3 = properties.Color
                frame.BackgroundTransparency = 1 - properties.Transparency
            end
            
            if properties.Filled then
                point1Frame.Visible = false
                point2Frame.Visible = false
                point3Frame.Visible = false
                drawingObj.BackgroundColor3 = properties.Color
                drawingObj.BackgroundTransparency = 1 - properties.Transparency
            else
                point1Frame.Visible = true
                point2Frame.Visible = true
                point3Frame.Visible = true
                drawingObj.BackgroundTransparency = 1
                
                drawLine(point1Frame, pA, pB)
                drawLine(point2Frame, pB, pC)
                drawLine(point3Frame, pC, pA)
            end
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "PointA" or k == "PointB" or k == "PointC" or k == "Filled" or k == "Thickness" or k == "Color" or k == "Transparency" then
                updateTriangle()
            end
        end
        
    elseif drawingType == "Quad" then
        drawingObj:Destroy()
        
        drawingObj = Instance.new("Frame")
        drawingObj.BackgroundTransparency = 1
        drawingObj.BorderSizePixel = 0
        drawingObj.Size = UDim2.fromOffset(100, 100)
        drawingObj.Parent = UI
        
        local line1 = Instance.new("Frame")
        line1.AnchorPoint = Vector2.new(0.5, 0.5)
        line1.BackgroundColor3 = Color3.new(1, 1, 1)
        line1.BorderSizePixel = 0
        line1.Parent = drawingObj
        
        local line2 = Instance.new("Frame")
        line2.AnchorPoint = Vector2.new(0.5, 0.5)
        line2.BackgroundColor3 = Color3.new(1, 1, 1)
        line2.BorderSizePixel = 0
        line2.Parent = drawingObj
        
        local line3 = Instance.new("Frame")
        line3.AnchorPoint = Vector2.new(0.5, 0.5)
        line3.BackgroundColor3 = Color3.new(1, 1, 1)
        line3.BorderSizePixel = 0
        line3.Parent = drawingObj
        
        local line4 = Instance.new("Frame")
        line4.AnchorPoint = Vector2.new(0.5, 0.5)
        line4.BackgroundColor3 = Color3.new(1, 1, 1)
        line4.BorderSizePixel = 0
        line4.Parent = drawingObj
        
        properties.PointA = Vector2.zero
        properties.PointB = Vector2.new(100, 0)
        properties.PointC = Vector2.new(100, 100)
        properties.PointD = Vector2.new(0, 100)
        properties.Filled = false
        properties.Thickness = 1
        
        local updateQuad = function()
            if removed then return end
            
            local pA = properties.PointA
            local pB = properties.PointB
            local pC = properties.PointC
            local pD = properties.PointD
            
            local minX = math.min(pA.X, pB.X, pC.X, pD.X)
            local minY = math.min(pA.Y, pB.Y, pC.Y, pD.Y)
            local maxX = math.max(pA.X, pB.X, pC.X, pD.X)
            local maxY = math.max(pA.Y, pB.Y, pC.Y, pD.Y)
            
            drawingObj.Position = UDim2.fromOffset(minX, minY)
            drawingObj.Size = UDim2.fromOffset(maxX - minX, maxY - minY)
            
            local function drawLine(frame, p1, p2)
                local dx = p2.X - p1.X
                local dy = p2.Y - p1.Y
                local length = math.sqrt(dx * dx + dy * dy)
                
                frame.Size = UDim2.fromOffset(length, properties.Thickness)
                frame.Position = UDim2.fromOffset((p1.X + p2.X) / 2 - minX, (p1.Y + p2.Y) / 2 - minY)
                frame.Rotation = math.deg(math.atan2(dy, dx))
                frame.BackgroundColor3 = properties.Color
                frame.BackgroundTransparency = 1 - properties.Transparency
            end
            
            if properties.Filled then
                line1.Visible = false
                line2.Visible = false
                line3.Visible = false
                line4.Visible = false
                drawingObj.BackgroundColor3 = properties.Color
                drawingObj.BackgroundTransparency = 1 - properties.Transparency
            else
                line1.Visible = true
                line2.Visible = true
                line3.Visible = true
                line4.Visible = true
                drawingObj.BackgroundTransparency = 1
                
                drawLine(line1, pA, pB)
                drawLine(line2, pB, pC)
                drawLine(line3, pC, pD)
                drawLine(line4, pD, pA)
            end
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "PointA" or k == "PointB" or k == "PointC" or k == "PointD" or k == "Filled" or k == "Thickness" or k == "Color" or k == "Transparency" then
                updateQuad()
            end
        end
        
    elseif drawingType == "Text" then
        drawingObj:Destroy()
        
        drawingObj = Instance.new("TextLabel")
        drawingObj.BackgroundTransparency = 1
        drawingObj.BorderSizePixel = 0
        drawingObj.TextColor3 = Color3.new(1, 1, 1)
        drawingObj.TextSize = 13
        drawingObj.Font = Enum.Font.Code
        drawingObj.Text = ""
        drawingObj.AutomaticSize = Enum.AutomaticSize.XY
        drawingObj.Parent = UI
        
        properties.Text = ""
        properties.Size = 13
        properties.Center = false
        properties.Outline = false
        properties.OutlineColor = Color3.new(0, 0, 0)
        properties.Position = Vector2.zero
        properties.Font = 2
        properties.TextBounds = Vector2.zero
        
        local updateText = function()
            if removed then return end
            
            drawingObj.Text = tostring(properties.Text)
            drawingObj.TextSize = properties.Size
            drawingObj.Position = UDim2.fromOffset(properties.Position.X, properties.Position.Y)
            drawingObj.TextColor3 = properties.Color
            drawingObj.TextTransparency = 1 - properties.Transparency
            drawingObj.Font = Fonts[properties.Font] or Enum.Font.Code
            
            if properties.Center then
                drawingObj.TextXAlignment = Enum.TextXAlignment.Center
                drawingObj.TextYAlignment = Enum.TextYAlignment.Center
            else
                drawingObj.TextXAlignment = Enum.TextXAlignment.Left
                drawingObj.TextYAlignment = Enum.TextYAlignment.Top
            end
            
            if properties.Outline then
                drawingObj.TextStrokeTransparency = 0
                drawingObj.TextStrokeColor3 = properties.OutlineColor
            else
                drawingObj.TextStrokeTransparency = 1
            end
            
            game:GetService("RunService").RenderStepped:Wait()
            properties.TextBounds = drawingObj.TextBounds
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k ~= "TextBounds" then
                task.spawn(updateText)
            end
        end
        
    elseif drawingType == "Image" then
        drawingObj:Destroy()
        
        drawingObj = Instance.new("ImageLabel")
        drawingObj.BackgroundTransparency = 1
        drawingObj.BorderSizePixel = 0
        drawingObj.Parent = UI
        
        properties.Data = ""
        properties.Size = Vector2.zero
        properties.Position = Vector2.zero
        properties.Rounding = 0
        
        local updateImage = function()
            if removed then return end
            
            drawingObj.Image = properties.Data
            drawingObj.Size = UDim2.fromOffset(properties.Size.X, properties.Size.Y)
            drawingObj.Position = UDim2.fromOffset(properties.Position.X, properties.Position.Y)
            drawingObj.ImageTransparency = 1 - properties.Transparency
            drawingObj.ImageColor3 = properties.Color
        end
        
        local oldNewindex = mt.__newindex
        mt.__newindex = function(t, k, v)
            oldNewindex(t, k, v)
            if k == "Data" or k == "Size" or k == "Position" or k == "Transparency" or k == "Color" then
                updateImage()
            end
        end
    end
    
    return self
end

getgenv().Drawing = Drawing

getgenv().isrenderobj = function(obj)
    if type(obj) ~= "userdata" then
        return false
    end
    
    local success, exists = pcall(function()
        return obj.__OBJECT_EXISTS
    end)
    
    return success and exists == true
end

getgenv().cleardrawcache = function()
    for i = #DrawingCache, 1, -1 do
        local data = DrawingCache[i]
        if data and data.proxy then
            pcall(function()
                data.proxy:Remove()
            end)
        end
    end
    
    DrawingCache = {}
    DrawingObjects = {}
end

getgenv().getrenderproperty = function(obj, prop)
    if not getgenv().isrenderobj(obj) then
        return nil
    end
    return obj[prop]
end

getgenv().setrenderproperty = function(obj, prop, value)
    if not getgenv().isrenderobj(obj) then
        return
    end
    obj[prop] = value
end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local parentGui
if gethui then
	parentGui = gethui()
else
	parentGui = game:GetService("CoreGui")
end

local COLOR_BG = Color3.fromRGB(24, 24, 27)
local COLOR_BG_LIGHT = Color3.fromRGB(30, 30, 33)
local COLOR_BORDER = Color3.fromRGB(50, 50, 54)
local COLOR_ACCENT = Color3.fromRGB(66, 133, 244)
local COLOR_TEXT = Color3.fromRGB(230, 230, 232)
local COLOR_SUBTEXT = Color3.fromRGB(150, 150, 156)

local NOTIF_WIDTH = 300
local NOTIF_HEIGHT = 64
local NOTIF_GAP = 10
local NOTIF_TOP = 20
local NOTIF_RIGHT = 20

local ICON_URL = "https://i.postimg.cc/rFL4SFvf/64x64.png"
local ICON_PATH = "ArquesNotificationIcon.png"
local iconAssetId = nil

local ok, err = pcall(function()
	if not isfile or not isfile(ICON_PATH) then
		local data = game:HttpGet(ICON_URL)
		writefile(ICON_PATH, data)
	end
	iconAssetId = getcustomasset(ICON_PATH)
end)
if not ok then
	warn("[Arques] Failed to load icon: " .. tostring(err))
end

local screenGui = parentGui:FindFirstChild("ArquesNotificationContainer")
if not screenGui then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ArquesNotificationContainer"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = parentGui
end

local function targetYFor(index)
	return NOTIF_TOP + (index - 1) * (NOTIF_HEIGHT + NOTIF_GAP)
end

local function getActiveFrames()
	local frames = {}
	for _, child in ipairs(screenGui:GetChildren()) do
		if child.Name == "Notification" and not child:GetAttribute("Removing") then
			table.insert(frames, child)
		end
	end
	return frames
end

local function reflow()
	local frames = getActiveFrames()
	for i, f in ipairs(frames) do
		if not f:GetAttribute("Dragging") then
			TweenService:Create(
				f,
				TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{Position = UDim2.new(1, -NOTIF_RIGHT, 0, targetYFor(i))}
			):Play()
		end
	end
end

local function showArquesNotification(titleText, subtitleText)
	titleText = titleText or "Arques"
	subtitleText = subtitleText or "has been loaded"

	local myIndex = #getActiveFrames() + 1
	local myTargetY = targetYFor(myIndex)

	local frame = Instance.new("Frame")
	frame.Name = "Notification"
	frame.AnchorPoint = Vector2.new(1, 0)
	frame.Position = UDim2.new(1, 40, 0, myTargetY)
	frame.Size = UDim2.new(0, NOTIF_WIDTH, 0, NOTIF_HEIGHT)
	frame.BackgroundColor3 = COLOR_BG
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = COLOR_BORDER
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = frame

	local titleStrip = Instance.new("Frame")
	titleStrip.Name = "TitleStrip"
	titleStrip.Size = UDim2.new(1, 0, 0, 4)
	titleStrip.BackgroundColor3 = COLOR_BG_LIGHT
	titleStrip.BorderSizePixel = 0
	titleStrip.ZIndex = 1
	titleStrip.Parent = frame

	local titleStripCorner = Instance.new("UICorner")
	titleStripCorner.CornerRadius = UDim.new(0, 6)
	titleStripCorner.Parent = titleStrip

	local accent = Instance.new("Frame")
	accent.Name = "Accent"
	accent.Position = UDim2.new(0, 0, 0, 0)
	accent.Size = UDim2.new(0, 4, 1, 0)
	accent.BackgroundColor3 = COLOR_ACCENT
	accent.BorderSizePixel = 0
	accent.ZIndex = 3
	accent.Parent = frame

	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(0, 3)
	accentCorner.Parent = accent

	local iconHolder = Instance.new("Frame")
	iconHolder.Size = UDim2.new(0, 26, 0, 26)
	iconHolder.Position = UDim2.new(0, 16, 0.5, -13)
	iconHolder.BackgroundTransparency = 1
	iconHolder.Parent = frame

	local iconImage = Instance.new("ImageLabel")
	iconImage.BackgroundTransparency = 1
	iconImage.Size = UDim2.new(1, -6, 1, -6)
	iconImage.Position = UDim2.new(0, 3, 0, 3)
	iconImage.ScaleType = Enum.ScaleType.Fit
	iconImage.Image = iconAssetId or "rbxassetid://0"
	iconImage.Parent = iconHolder

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 54, 0, 10)
	title.Size = UDim2.new(1, -86, 0, 20)
	title.Text = titleText
	title.TextColor3 = COLOR_TEXT
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local subtitle = Instance.new("TextLabel")
	subtitle.BackgroundTransparency = 1
	subtitle.Position = UDim2.new(0, 54, 0, 30)
	subtitle.Size = UDim2.new(1, -86, 0, 18)
	subtitle.Text = subtitleText
	subtitle.TextColor3 = COLOR_SUBTEXT
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 12
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.Parent = frame

	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 22, 0, 22)
	closeBtn.Position = UDim2.new(1, -30, 0, 9)
	closeBtn.BackgroundColor3 = COLOR_BG_LIGHT
	closeBtn.BackgroundTransparency = 1
	closeBtn.AutoButtonColor = false
	closeBtn.Text = "×"
	closeBtn.TextColor3 = COLOR_SUBTEXT
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 17
	closeBtn.Parent = frame

	local closeBtnCorner = Instance.new("UICorner")
	closeBtnCorner.CornerRadius = UDim.new(0, 5)
	closeBtnCorner.Parent = closeBtn

	closeBtn.MouseEnter:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), {TextColor3 = COLOR_TEXT, BackgroundTransparency = 0}):Play()
	end)
	closeBtn.MouseLeave:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), {TextColor3 = COLOR_SUBTEXT, BackgroundTransparency = 1}):Play()
	end)

	local slideIn = TweenService:Create(
		frame,
		TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		{Position = UDim2.new(1, -NOTIF_RIGHT, 0, myTargetY)}
	)

	local function fadeChildren(alpha)
		for _, child in ipairs(frame:GetDescendants()) do
			if child:IsA("TextLabel") or child:IsA("TextButton") then
				TweenService:Create(child, TweenInfo.new(0.08), {TextTransparency = alpha}):Play()
			elseif child:IsA("ImageLabel") then
				TweenService:Create(child, TweenInfo.new(0.08), {ImageTransparency = alpha}):Play()
			elseif child:IsA("Frame") and child.Name ~= "Accent" then
				TweenService:Create(child, TweenInfo.new(0.08), {BackgroundTransparency = alpha}):Play()
			end
		end
	end

	local dismissed = false
	local function dismiss()
		if dismissed then return end
		dismissed = true

		frame:SetAttribute("Removing", true)
		reflow()

		local absPos = frame.AbsolutePosition
		local absSize = frame.AbsoluteSize
		local centerX = absPos.X + absSize.X / 2
		local centerY = absPos.Y + absSize.Y / 2

		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.new(0, centerX, 0, centerY)

		local fullWidth = absSize.X

		fadeChildren(1)
		accent.Visible = false
		titleStrip.Visible = false
		stroke.Enabled = false
		corner.CornerRadius = UDim.new(0, 0)

		local squashY = TweenService:Create(
			frame,
			TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{Size = UDim2.new(0, fullWidth, 0, 3), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}
		)
		squashY:Play()
		squashY.Completed:Wait()

		task.wait(0.04)

		local squashX = TweenService:Create(
			frame,
			TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{Size = UDim2.new(0, 0, 0, 3), BackgroundColor3 = Color3.fromRGB(200, 220, 255), BackgroundTransparency = 1}
		)
		squashX:Play()
		squashX.Completed:Wait()

		frame:Destroy()
	end

	closeBtn.MouseButton1Click:Connect(dismiss)

	local dragging = false
	local dragStart, startPos

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			frame:SetAttribute("Dragging", true)
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			if delta.X > 0 then
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset)
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			frame:SetAttribute("Dragging", false)
			local dragThreshold = 60
			local delta = frame.Position.X.Offset - (UDim2.new(1, -NOTIF_RIGHT, 0, myTargetY)).X.Offset
			if delta > dragThreshold then
				dismiss()
			else
				TweenService:Create(
					frame,
					TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{Position = UDim2.new(1, -NOTIF_RIGHT, 0, myTargetY)}
				):Play()
			end
		end
	end)

	slideIn:Play()

	task.delay(5, dismiss)
end

showArquesNotification("Arques", "has been loaded")
