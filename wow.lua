
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


  local env = getgenv()
  local coreGui = game:GetService("CoreGui")
  local camera = workspace.CurrentCamera
  
  local old = coreGui:FindFirstChild("ArquesDrawingUD")
  if old then old:Destroy() end
  
  local drawingUI = Instance.new("ScreenGui")
  drawingUI.Name = "ArquesDrawingUD"
  drawingUI.IgnoreGuiInset = true
  drawingUI.DisplayOrder = 0x7fffffff
  drawingUI.ResetOnSpawn = false
  drawingUI.Parent = coreGui
  
  local fonts = {
      [0] = Font.fromEnum(Enum.Font.Roboto),
      [1] = Font.fromEnum(Enum.Font.Legacy),
      [2] = Font.fromEnum(Enum.Font.SourceSans),
      [3] = Font.fromEnum(Enum.Font.RobotoMono),
  }
  
  local Drawing = {
      Fonts = {
          UI = 0,
          System = 1,
          Plex = 2,
          Monospace = 3,
      },
  }
  
  local objects = setmetatable({}, { __mode = "k" })
  local nextId = 0
  
  local defaults = {
      Line = {
          From = Vector2.zero,
          To = Vector2.zero,
          Thickness = 1,
      },
      Text = {
          Text = "",
          TextBounds = Vector2.zero,
          Font = 0,
          Size = 13,
          Position = Vector2.zero,
          Center = false,
          Outline = false,
          OutlineColor = Color3.new(),
      },
      Image = {
          Data = "",
          DataURL = "",
          Size = Vector2.zero,
          Position = Vector2.zero,
      },
      Circle = {
          NumSides = 0,
          Radius = 0,
          Position = Vector2.zero,
          Thickness = 1,
          Filled = false,
      },
      Square = {
          Size = Vector2.zero,
          Position = Vector2.zero,
          Thickness = 1,
          Filled = false,
      },
      Quad = {
          PointA = Vector2.zero,
          PointB = Vector2.zero,
          PointC = Vector2.zero,
          PointD = Vector2.zero,
          Thickness = 1,
          Filled = false,
      },
      Triangle = {
          PointA = Vector2.zero,
          PointB = Vector2.zero,
          PointC = Vector2.zero,
          Thickness = 1,
          Filled = false,
      },
      Frame = {
          Size = UDim2.fromOffset(100, 100),
          Position = UDim2.fromOffset(0, 0),
      },
      ScreenGui = {
          IgnoreGuiInset = true,
          DisplayOrder = 0,
          ResetOnSpawn = false,
          ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
          Enabled = true,
      },
      TextButton = {
          Text = "Button",
          Font = 0,
          Size = 20,
          Position = UDim2.fromOffset(0, 0),
          BackgroundColor = Color3.fromRGB(51, 51, 51),
          MouseButton1Click = false,
      },
      TextLabel = {
          Text = "Label",
          Font = 0,
          Size = 20,
          Position = UDim2.fromOffset(0, 0),
          BackgroundColor = Color3.fromRGB(51, 51, 51),
      },
      TextBox = {
          Text = "",
          Font = 0,
          Size = 20,
          Position = UDim2.fromOffset(0, 0),
          BackgroundColor = Color3.fromRGB(51, 51, 51),
      },
  }
  
  local function copyDefaults(kind)
      local state = {
          Visible = false,
          ZIndex = 0,
          Transparency = 1,
          Color = Color3.new(),
          __OBJECT_EXISTS = true,
          Parent = drawingUI,
      }
      for key, value in pairs(defaults[kind]) do
          state[key] = value
      end
      return state
  end
  
  local function alpha(value)
      return math.clamp(value, 0, 1)
  end
  
  local function makeGui(kind)
      if kind == "Line" then
       
        local gui = Instance.new("ImageLabel")
          gui.Image = ""
          gui.BorderSizePixel = 0
          gui.AnchorPoint = Vector2.new(0.5, 0.5)
          return gui
      elseif kind == "Text" or kind == "TextLabel" then
          local gui = Instance.new("TextLabel")
          gui.BackgroundTransparency = 1
          gui.BorderSizePixel = 0
          return gui
      elseif kind == "TextButton" then
          local gui = Instance.new("TextButton")
          gui.BorderSizePixel = 0
          return gui
      elseif kind == "TextBox" then
          local gui = Instance.new("TextBox")
          gui.BorderSizePixel = 0
          return gui
      elseif kind == "Image" then
          local gui = Instance.new("ImageLabel")
          gui.BackgroundTransparency = 1
          gui.BorderSizePixel = 0
          return gui
      elseif kind == "ScreenGui" then
          return Instance.new("ScreenGui")
      end
  
      local gui = Instance.new("Frame")
      gui.BorderSizePixel = 0
      if kind == "Circle" then
          local corner = Instance.new("UICorner")
          corner.CornerRadius = UDim.new(1, 0)
          corner.Parent = gui
      end
      return gui
  end
  
  local function updateLine(gui, state)
      local delta = state.To - state.From
      local center = (state.To + state.From) / 2
      gui.Position = UDim2.fromOffset(center.X, center.Y)
      gui.Size = UDim2.fromOffset(delta.Magnitude, state.Thickness)
      gui.Rotation = math.deg(math.atan2(delta.Y, delta.X))
  end
  
  local function updateGui(kind, gui, state, property)
      if not gui or not gui.Parent and state.__OBJECT_EXISTS == false then return end
  
      if property == nil or property == "Visible" then
          if gui:IsA("GuiObject") then gui.Visible = state.Visible end
      end
      if property == nil or property == "ZIndex" then
          if gui:IsA("GuiObject") then gui.ZIndex = state.ZIndex end
      end
      if property == nil or property == "Parent" then
          gui.Parent = state.Parent
      end
  
      if kind == "Line" then
          if property == nil or property == "From" or property == "To" or property == "Thickness" then
              updateLine(gui, state)
          end
          if property == nil or property == "Color" then gui.BackgroundColor3 = state.Color end
          if property == nil or property == "Transparency" then gui.BackgroundTransparency = alpha(state.Transparency) end
      elseif kind == "Text" then
          if property == nil or property == "Text" then gui.Text = state.Text end
          if property == nil or property == "Font" then gui.FontFace = fonts[math.clamp(state.Font, 0, 3)] end
          if property == nil or property == "Size" then gui.TextSize = state.Size end
          if property == nil or property == "Position" or property == "Center" then
              local position = state.Center and camera.ViewportSize / 2 or state.Position
              gui.Position = UDim2.fromOffset(position.X, position.Y)
          end
          if property == nil or property == "Color" then gui.TextColor3 = state.Color end
          if property == nil or property == "Transparency" then gui.TextTransparency = alpha(state.Transparency) end
          state.TextBounds = gui.TextBounds
      elseif kind == "Image" then
          if property == nil or property == "DataURL" then gui.Image = state.DataURL end
          if property == nil or property == "Size" then gui.Size = UDim2.fromOffset(state.Size.X, state.Size.Y) end
          if property == nil or property == "Position" then gui.Position = UDim2.fromOffset(state.Position.X, state.Position.Y) end
          if property == nil or property == "Color" then gui.ImageColor3 = state.Color end
          if property == nil or property == "Transparency" then gui.ImageTransparency = alpha(state.Transparency) end
      elseif kind == "Circle" then
          if property == nil or property == "Radius" then
              gui.Size = UDim2.fromOffset(state.Radius * 2, state.Radius * 2)
          end
          if property == nil or property == "Position" then gui.Position = UDim2.fromOffset(state.Position.X, state.Position.Y) end
          if property == nil or property == "Color" then gui.BackgroundColor3 = state.Color end
          if property == nil or property == "Transparency" or property == "Filled" then
              gui.BackgroundTransparency = state.Filled and alpha(state.Transparency) or 1
          end
      elseif kind == "Square" then
          if property == nil or property == "Size" then gui.Size = UDim2.fromOffset(state.Size.X, state.Size.Y) end
          if property == nil or property == "Position" then gui.Position = UDim2.fromOffset(state.Position.X, state.Position.Y) end
          if property == nil or property == "Color" then gui.BackgroundColor3 = state.Color end
          if property == nil or property == "Transparency" or property == "Filled" then
              gui.BackgroundTransparency = state.Filled and alpha(state.Transparency) or 1
          end
      elseif kind == "Frame" then
          gui.Size = state.Size
          gui.Position = state.Position
          gui.BackgroundColor3 = state.Color
          gui.BackgroundTransparency = alpha(state.Transparency)
      elseif kind == "ScreenGui" then
          gui.IgnoreGuiInset = state.IgnoreGuiInset
          gui.DisplayOrder = state.DisplayOrder
          gui.ResetOnSpawn = state.ResetOnSpawn
          gui.ZIndexBehavior = state.ZIndexBehavior
          gui.Enabled = state.Enabled
      elseif kind == "TextButton" or kind == "TextLabel" or kind == "TextBox" then
          gui.Text = state.Text
          gui.FontFace = fonts[math.clamp(state.Font, 0, 3)]
          gui.TextSize = state.Size
          gui.Position = state.Position
          gui.TextColor3 = state.Color
          gui.BackgroundColor3 = state.BackgroundColor
          gui.BackgroundTransparency = alpha(state.Transparency)
      else
          gui.BackgroundColor3 = state.Color
          gui.BackgroundTransparency = alpha(state.Transparency)
      end
  end
  
  local function create(kind)
      if defaults[kind] == nil then
          error("Invalid drawing type: " .. tostring(kind), 2)
      end
  
      nextId += 1
      local state = copyDefaults(kind)
      local gui = makeGui(kind)
      gui.Name = tostring(nextId)
      if kind == "ScreenGui" then
          state.Parent = coreGui
          gui.Parent = coreGui
      else
          gui.Parent = drawingUI
      end
  
      local proxy
      local function destroy()
          if not state.__OBJECT_EXISTS then return end
          state.__OBJECT_EXISTS = false
          objects[proxy] = nil
          gui:Destroy()
      end
  
      state.Destroy = destroy
      state.Remove = destroy
      state.SetProperty = function(_, key, value) proxy[key] = value end
      state.GetProperty = function(_, key) return proxy[key] end
      state.SetParent = function(_, parent) proxy.Parent = parent end
  
      proxy = newproxy(true)
      local mt = getmetatable(proxy)
      mt.__index = function(_, key)
          return state[key]
      end
      mt.__newindex = function(_, key, value)
          local known = state[key] ~= nil
          state[key] = value
          if known then
              updateGui(kind, gui, state, key)
          end
      end
      mt.__tostring = function()
          return "Drawing"
      end
      mt.__metatable = "The metatable is locked"
  
      objects[proxy] = true
      updateGui(kind, gui, state, nil)
      return proxy
  end
  
  Drawing.new = create
  Drawing.createLine = function() return create("Line") end
  Drawing.createText = function() return create("Text") end
  Drawing.createCircle = function() return create("Circle") end
  Drawing.createSquare = function() return create("Square") end
  Drawing.createImage = function() return create("Image") end
  Drawing.createQuad = function() return create("Quad") end
  Drawing.createTriangle = function() return create("Triangle") end
  Drawing.createFrame = function() return create("Frame") end
  Drawing.createScreenGui = function() return create("ScreenGui") end
  Drawing.createTextButton = function() return create("TextButton") end
  Drawing.createTextLabel = function() return create("TextLabel") end
  Drawing.createTextBox = function() return create("TextBox") end
  
  env.Drawing = Drawing
  env.isrenderobj = function(object)
      if type(object) ~= "userdata" or objects[object] ~= true then
          return false
      end
      local ok, exists = pcall(function()
          return object.__OBJECT_EXISTS
      end)
      return ok and exists == true
  end
  env.getrenderproperty = function(object, property)
      return object[property]
  end
  env.setrenderproperty = function(object, property, value)
      object[property] = value
  end
  env.cleardrawcache = function()
      local pending = {}
      for object in pairs(objects) do pending[#pending + 1] = object end
      for _, object in ipairs(pending) do object:Destroy() end
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
