--[[
	
	- [ stav.lua ] -
	Monsoon :3
	
	CREATED: [ 18/11 ]
	
]]

local lib = {
	API = {},
	connections = {}
}

local cloneref = cloneref or function(obj)
	return obj
end

local inputService = cloneref(game:GetService('UserInputService'))
local tweenService = cloneref(game:GetService('TweenService'))
local httpService = cloneref(game:GetService('HttpService'))
local textService = cloneref(game:GetService('TextService'))
local playersService = cloneref(game:GetService('Players'))
local runService = cloneref(game:GetService('RunService'))
local lplr = playersService.LocalPlayer

local gameCamera = workspace.CurrentCamera
local gethui = get_hidden_ui or gethui or function()
	return (runService:IsStudio() and lplr.PlayerGui) or cloneref(game:GetService('CoreGui'))
end

local ScreenGUI = Instance.new('ScreenGui')
ScreenGUI.Name = '\0'
ScreenGUI.ResetOnSpawn = false
ScreenGUI.Parent = gethui()

local Scale = Instance.new('UIScale')
Scale.Parent = ScreenGUI
Scale.Scale = math.min(gameCamera.ViewportSize.X / 1920, gameCamera.ViewportSize.Y / 1080)

table.insert(lib.connections, gameCamera:GetPropertyChangedSignal('ViewportSize'):Connect(function()
	Scale.Scale = math.min(gameCamera.ViewportSize.X / 1920, gameCamera.ViewportSize.Y / 1080)
end))

local ArrayGUI = Instance.new('ScreenGui')
ArrayGUI.Name = '\0'
ArrayGUI.ResetOnSpawn = false
ArrayGUI.IgnoreGuiInset = true
ArrayGUI.Parent = gethui()

local ArrayScale = Instance.new('UIScale')
ArrayScale.Parent = ArrayGUI
ArrayScale.Scale = math.min(gameCamera.ViewportSize.X / 1920, gameCamera.ViewportSize.Y / 1080)

table.insert(lib.connections, gameCamera:GetPropertyChangedSignal('ViewportSize'):Connect(function()
	ArrayScale.Scale = math.min(gameCamera.ViewportSize.X / 1920, gameCamera.ViewportSize.Y / 1080)
end))

lib.API.themes = {
	theme = 'Monsoon',
	Main = {
		Astolfo = Color3.fromRGB(81, 56, 95),
		Monsoon = Color3.fromRGB(51, 61, 95)
	},
	Secondary = {
		Astolfo = Color3.fromRGB(220, 151, 255),
		Monsoon = Color3.fromRGB(137, 165, 255)
	},
	Third = {
		Astolfo = Color3.fromRGB(60, 42, 71),
		Monsoon = Color3.fromRGB(35, 43, 66)
	},
	MiniToggle = {
		Astolfo = Color3.fromRGB(67, 46, 79),
		Monsoon = Color3.fromRGB(45, 55, 79)
	},
	Sliders = {
		Astolfo = Color3.fromRGB(106, 74, 126),
		Monsoon = Color3.fromRGB(57, 72, 109)
	}
}

local cfg = {}
local configSys = {
	canSave = true,
	file = 'Astolfo/configs/'..game.PlaceId..'.json',
	Save = function(self)
		if runService:IsStudio() then return end
		if not self.canSave then return end

		writefile(self.file, httpService:JSONEncode(cfg))
	end,
	Load = function(self)
		if runService:IsStudio() then return end

		if isfile(self.file) then
			cfg = httpService:JSONDecode(readfile(self.file))
		end
	end
}

if not runService:IsStudio() then
	for _, v in {'Astolfo', 'Astolfo/configs'} do
		if not isfolder(v) then
			makefolder(v)
		end
	end
end

local index = 0
local Windows = {}
local Array = {}

local ArrayFrame = Instance.new('Frame')
ArrayFrame.AnchorPoint = Vector2.new(0.995, 0.05)
ArrayFrame.Position = UDim2.fromScale(0.995, 0.05)
ArrayFrame.Size = UDim2.fromScale(0.2, 0.85)
ArrayFrame.BackgroundTransparency = 1
ArrayFrame.BorderSizePixel = 0
ArrayFrame.Parent = ArrayGUI

local ArrayLayout = Instance.new('UIListLayout')
ArrayLayout.Parent = ArrayFrame
ArrayLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ArrayLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function AddArray(name)
	local Text = Instance.new('TextLabel')
	Text.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Text.BackgroundTransparency = 0.75
	Text.TextTransparency = 1
	Text.BorderSizePixel = 0
	Text.Text = name
	Text.TextColor3 = lib.API.themes.Secondary[lib.API.themes.theme]
	Text.TextSize = 12
	Text.ZIndex = -1
	Text.Name = name
	Text.TextYAlignment = Enum.TextYAlignment.Center
	Text.TextXAlignment = Enum.TextXAlignment.Center
	Text.Parent = ArrayFrame

	local maxWidth = ArrayFrame.AbsoluteSize.X
	local textSize = textService:GetTextSize(' '..name..' ', Text.TextSize, Text.Font, Vector2.new(maxWidth, 1 / 0))
    Text.Size = UDim2.new(0, 0, 0, 22)
	local NewSize = UDim2.new(0, textSize.X, 0, 22)

	table.insert(Array, Text)

	if name == '' then
		NewSize = UDim2.new(0, 0, 0, 0)
	end

	local ArrayIn = tweenService:Create(Text, TweenInfo.new(0.3), {Size = NewSize, Position = UDim2.new(1, -textSize.X, 0, 0)})
	if ArrayIn then
		ArrayIn:Play()

		table.insert(lib.connections, ArrayIn.Completed:Connect(function()
			Text.TextTransparency = 0
		end))
	end

	table.sort(Array, function(a, b)
		return textService:GetTextSize(a.Text, a.TextSize, a.Font, Vector2.new(maxWidth, 1 / 0)).X > textService:GetTextSize(b.Text, b.TextSize, b.Font, Vector2.new(maxWidth, 1 / 0)).X
	end)

	for i, v in Array do
		v.LayoutOrder = i
	end
end

local function RemoveArray(name)
	local maxWidth = ArrayFrame.AbsoluteSize.X
	table.sort(Array, function(a, b)
		return textService:GetTextSize(a.Text, a.TextSize, a.Font, Vector2.new(maxWidth, 1 / 0)).X > textService:GetTextSize(b.Text, b.TextSize, b.Font, Vector2.new(maxWidth, 1 / 0)).X
	end)

	for i,v in Array do
		if v.Text == name then
			v.TextTransparency = 1
			local textSize = textService:GetTextSize(' '..name..' ', v.TextSize, v.Font, Vector2.new(maxWidth, 1 / 0))
			local ArrayOut = tweenService:Create(v, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 20)})
			if ArrayOut then
				ArrayOut:Play()

				table.insert(lib.connections, ArrayOut.Completed:Connect(function()
					v:Destroy()
					table.remove(Array, i)
				end))
			end
		end
	end

	for i, v in Array do
		v.LayoutOrder = i
	end
end

local TargetFrame = Instance.new("Frame")
TargetFrame.Parent = ScreenGUI
TargetFrame.AnchorPoint = Vector2.new(0.5, 0.5)
TargetFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TargetFrame.BackgroundTransparency = 0.15
TargetFrame.BorderSizePixel = 0
TargetFrame.Size = UDim2.new(0, 231, 0, 50)
TargetFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TargetFrame.Visible = false

local TargetImage = Instance.new("ImageLabel")
TargetImage.Parent = TargetFrame
TargetImage.AnchorPoint = Vector2.new(0, 0.5)
TargetImage.BackgroundTransparency = 1
TargetImage.Position = UDim2.new(0, 5, 0.5, 0)
TargetImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TargetImage.Size = UDim2.new(0, 40, 0, 40)

local TargetName = Instance.new("TextLabel")
TargetName.Parent = TargetFrame
TargetName.BackgroundTransparency = 1
TargetName.Font = Enum.Font.SourceSansBold
TargetName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TargetName.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetName.TextSize = 18
TargetName.TextWrapped = true
TargetName.TextXAlignment = Enum.TextXAlignment.Left

local HealthBack = Instance.new("Frame")
HealthBack.Parent = TargetFrame
HealthBack.AnchorPoint = Vector2.new(0, 0.5)
HealthBack.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
HealthBack.BackgroundTransparency = 0.35
HealthBack.Position = UDim2.new(0, 50, 0.75, 0)
HealthBack.Size = UDim2.new(0, 100, 0, 8)
HealthBack.BorderSizePixel = 0

local HealthFront = Instance.new("Frame")
HealthFront.Parent = HealthBack
HealthFront.AnchorPoint = Vector2.new(0, 0.5)
HealthFront.BackgroundColor3 = lib.API.themes.Secondary[lib.API.themes.theme]
HealthFront.Position = UDim2.new(0, 0, 0.5, 0)
HealthFront.Size = UDim2.new(0, 50, 0, 8)
HealthFront.BorderSizePixel = 0

function lib.API:CreateTargetHUD(name, thumbnail, humanoid, ishere)
	local TargetHUD = {}

	if ishere then
		TargetFrame.Visible = true
		if name and humanoid then
			TargetImage.Image = thumbnail
			TargetName.Text = name

			local Calculation = humanoid.Health / humanoid.MaxHealth
			local NewTextSize = textService:GetTextSize(TargetName.Text, TargetName.TextSize, TargetName.Font, Vector2.new(9999, 50))
			local Width = NewTextSize.X + TargetImage.Size.X.Offset + 20
			local NewSize_2 = UDim2.new(0, Width, 0, 50)

			TargetFrame.Size = NewSize_2
			HealthBack.Size = UDim2.new(0, NewTextSize.X, 0, 8)
			TargetName.Size = UDim2.new(0, NewTextSize.X, 0, NewTextSize.Y)
			TargetName.Position = UDim2.new(0, HealthBack.Position.X.Offset, 0.12, 0)

			if humanoid.Health > 0 then
				tweenService:Create(HealthFront, TweenInfo.new(0.5), { Size = UDim2.new(Calculation, 0, 0, 8) }):Play()
			elseif humanoid.Health < 0 then
				tweenService:Create(HealthFront, TweenInfo.new(0.5), { Size = UDim2.new(-0, 0, 0, 8) }):Play()
			else
				tweenService:Create(HealthFront, TweenInfo.new(0.5), { Size = UDim2.new(-0, 0, 0, 8) }):Play()
			end
		end
	else
		TargetFrame.Visible = false
	end

	return TargetHUD
end

function lib.API.EnableArray(tog)
	ArrayFrame.Visible = tog
end

if inputService.TouchEnabled then
	--lplr:Kick('Not mobile supported for the time being :)')
end

configSys:Load()
task.wait(0.1)

for i,v in cfg do
	if type(v) == 'table' and v.Enabled then
		AddArray(i)
	end
end

local watermark
local watermarkimage
lib.API.Watermark = function(bool, txt)
	if bool == true and watermark == nil and watermarkimage == nil then
		watermark = Instance.new('TextLabel')
		watermark.AnchorPoint = Vector2.new(1, 1)
		watermark.Position = UDim2.new(1, -75, 1, -20)
		watermark.BackgroundTransparency = 1
		watermark.BorderSizePixel = 0
		watermark.Text = txt
		watermark.TextSize = 24
		watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
		watermark.Parent = ScreenGUI

		watermarkimage = Instance.new('ImageLabel')
		watermarkimage.AnchorPoint = Vector2.new(1, 1)
		watermarkimage.Position = UDim2.new(1, 0, 1, -20)
		watermarkimage.Size = UDim2.new(0, 160, 0, 160)
		watermarkimage.BackgroundTransparency = 1
		watermarkimage.BorderSizePixel = 0
		watermarkimage.Image = 'rbxassetid://10854660460'
		watermarkimage.Parent = ScreenGUI
	elseif bool == false and watermark ~= nil and watermarkimage ~= nil then
		watermark:Destroy()
		watermark = nil

		watermarkimage:Destroy()
		watermarkimage = nil
	end
end

lib.API.ChangeColor = function()
	for i,v in Windows do
		if v.Inst then
			v.Inst.BackgroundColor3 = lib.API.themes.Third[lib.API.themes.theme]
		end

		if v.BarInst then
			v.BarInst.BackgroundColor3 = lib.API.themes.Secondary[lib.API.themes.theme]
		end
	end

	for i,v in cfg do
		if v.Inst then
			v.Inst.BackgroundColor3 = v.Enabled and lib.API.themes.Secondary[lib.API.themes.theme] or lib.API.themes.Main[lib.API.themes.theme]
		end

		if v.KeybindInst then
			v.KeybindInst.BackgroundColor3 = lib.API.themes.Third[lib.API.themes.theme]
		end

		for x, d in v.Toggles do
			if d.Inst then
				d.Inst.BackgroundColor3 = d.Enabled and lib.API.themes.MiniToggle[lib.API.themes.theme] or lib.API.themes.Third[lib.API.themes.theme]
			end
		end

		for x,d in v.Sliders do
			if d.Inst then
				d.Inst.BackgroundColor3 = lib.API.themes.Third[lib.API.themes.theme]
			end

			if d.FillInst then
				d.FillInst.BackgroundColor3 = lib.API.themes.Sliders[lib.API.themes.theme]
			end
		end

		for x, d in v.Dropdowns do
			if d.Inst then
				d.Inst.BackgroundColor3 = lib.API.themes.Third[lib.API.themes.theme]
			end
		end
	end

	for i,v in Array do
		v.TextColor3 = lib.API.themes.Secondary[lib.API.themes.theme]
	end
end

lib.API.CreateWindow = function(txt)
	local WindowFrame = Instance.new('Frame')
	WindowFrame.Position = UDim2.fromScale(0.01 + (index / 8.2), 0.01)
	WindowFrame.Size = UDim2.new(0.12, 0, 0, 32)
	WindowFrame.BackgroundColor3 = lib.API.themes.Third[lib.API.themes.theme]
	WindowFrame.BorderSizePixel = 0
	WindowFrame.Parent = ScreenGUI

	local Bar = Instance.new('Frame')
	Bar.BackgroundColor3 = lib.API.themes.Secondary[lib.API.themes.theme]
	Bar.Size = UDim2.new(1, 0, 0, -3)
	Bar.AutomaticSize = Enum.AutomaticSize.X
	Bar.BorderSizePixel = 0
	Bar.Parent = WindowFrame 

	local WindowLabel = Instance.new('TextLabel')
	WindowLabel.Size = UDim2.fromScale(1, 1)
	WindowLabel.Position = UDim2.fromScale(0.05, 0)
	WindowLabel.BackgroundTransparency = 1
	WindowLabel.BorderSizePixel = 0
	WindowLabel.TextXAlignment = Enum.TextXAlignment.Left
	WindowLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	WindowLabel.TextSize = 12
	WindowLabel.AutomaticSize = Enum.AutomaticSize.X
	WindowLabel.Text = txt
	WindowLabel.Parent = WindowFrame

	local ModuleFrame = Instance.new('Frame')
	ModuleFrame.Position = UDim2.fromScale(0, 1)
	ModuleFrame.Size = UDim2.new(1, 0, 0, 0)
	ModuleFrame.BorderSizePixel = 0
	ModuleFrame.AutomaticSize = Enum.AutomaticSize.Y
	ModuleFrame.BackgroundTransparency = 1
	ModuleFrame.Parent = WindowFrame

	-- why roblox?
	local ModulePadding = Instance.new('UIPadding')
	ModulePadding.PaddingTop = UDim.new(0, 0)
	ModulePadding.Parent = ModuleFrame

	local ModuleSort = Instance.new('UIListLayout')
	ModuleSort.SortOrder = Enum.SortOrder.LayoutOrder
	ModuleSort.Parent = ModuleFrame

	table.insert(lib.connections, inputService.InputBegan:Connect(function(key, gpe)
		if gpe then return end

		if key.KeyCode == Enum.KeyCode.RightShift then
			WindowFrame.Visible = not WindowFrame.Visible
		end
	end))

	index += 1

	Windows[txt] = {
		Inst = WindowFrame,
		BarInst = Bar,
		Modules = {},
		CreateModule = function(self, Table)
			if type(cfg[Table.Name]) ~= 'table' then
				cfg[Table.Name] = {
					Enabled = false,
					Keybind = 'Unknown',
					Toggles = {},
					Dropdowns = {},
					Sliders = {}
				}
			end

			local ModuleButton = Instance.new('Frame')
			ModuleButton.Size = UDim2.new(1, 0, 0, 34)
			ModuleButton.BorderSizePixel = 0
			ModuleButton.BackgroundColor3 = cfg[Table.Name].Enabled and lib.API.themes.Secondary[lib.API.themes.theme] or lib.API.themes.Main[lib.API.themes.theme]
			ModuleButton.Parent = ModuleFrame

			cfg[Table.Name].Inst = ModuleButton

			local ModuleText = Instance.new('TextButton')
			ModuleText.Position = UDim2.fromScale(0.05, 0)
			ModuleText.Size = UDim2.fromScale(1, 1)
			ModuleText.BackgroundTransparency = 1
			ModuleText.BorderSizePixel = 0
			ModuleText.TextXAlignment = Enum.TextXAlignment.Left
			ModuleText.TextColor3 = Color3.fromRGB(255, 255, 255)
			ModuleText.TextSize = 12
			ModuleText.AutomaticSize = Enum.AutomaticSize.X
			ModuleText.Text = Table.Name
			ModuleText.Parent = ModuleButton

			local DropdownFrame = Instance.new('Frame')
			DropdownFrame.Size = UDim2.fromScale(1, 0)
			DropdownFrame.AutomaticSize = Enum.AutomaticSize.Y
			DropdownFrame.BackgroundTransparency = 1
			DropdownFrame.Visible = not DropdownFrame.Visible
			DropdownFrame.Parent = ModuleFrame

			local DropdownSort = Instance.new('UIListLayout')
			DropdownSort.SortOrder = Enum.SortOrder.LayoutOrder
			DropdownSort.Parent = DropdownFrame

			local moduleHandler = {
				Enabled = cfg[Table.Name].Enabled,
				Toggle = function(self)
					self.Enabled = not self.Enabled
					cfg[Table.Name].Enabled = not cfg[Table.Name].Enabled

					tweenService:Create(ModuleButton, TweenInfo.new(0.1), {BackgroundColor3 = self.Enabled and lib.API.themes.Secondary[lib.API.themes.theme] or lib.API.themes.Main[lib.API.themes.theme]}):Play()
					if Table.Function then
						task.spawn(Table.Function, self.Enabled)
					end

					if self.Enabled then
						task.spawn(AddArray, Table.Name)
					else
						task.spawn(RemoveArray, Table.Name)
					end

					configSys:Save()
				end,
			}

			function moduleHandler.CreateToggle(self, tab)
				if not cfg[Table.Name].Toggles[tab.Name] then
					cfg[Table.Name].Toggles[tab.Name] = {Enabled = false}
				end

				local ModuleFrame = Instance.new('Frame')
				ModuleFrame.Size = UDim2.new(1, 0, 0, 34)
				ModuleFrame.BackgroundColor3 = cfg[Table.Name].Toggles[tab.Name].Enabled and lib.API.themes.MiniToggle[lib.API.themes.theme] or lib.API.themes.Third[lib.API.themes.theme]
				ModuleFrame.BorderSizePixel = 0
				ModuleFrame.Parent = DropdownFrame

				cfg[Table.Name].Toggles[tab.Name].Inst = ModuleFrame

				local ModuleText = Instance.new('TextButton')
				ModuleText.Position = UDim2.fromScale(0.05, 0)
				ModuleText.Size = UDim2.fromScale(1, 1)
				ModuleText.BackgroundTransparency = 1
				ModuleText.TextXAlignment = Enum.TextXAlignment.Left
				ModuleText.TextColor3 = Color3.fromRGB(255, 255, 255)
				ModuleText.TextSize = 10
				ModuleText.Text = tab.Name
				ModuleText.Parent = ModuleFrame

				local moduleHandler = {
					Enabled = cfg[Table.Name].Toggles[tab.Name].Enabled,
					Toggle = function(self)
						self.Enabled = not self.Enabled
						cfg[Table.Name].Toggles[tab.Name].Enabled = not cfg[Table.Name].Toggles[tab.Name].Enabled

						tweenService:Create(ModuleFrame, TweenInfo.new(0.1), {BackgroundColor3 = self.Enabled and lib.API.themes.MiniToggle[lib.API.themes.theme] or lib.API.themes.Third[lib.API.themes.theme]}):Play()
						if tab.Function then
							task.spawn(tab.Function, self.Enabled)
						end

						configSys:Save()
					end,
				}

				table.insert(lib.connections, ModuleText.MouseButton1Click:Connect(function()
					moduleHandler:Toggle()
				end))

				if cfg[Table.Name].Toggles[tab.Name].Enabled and tab.Function then
					task.delay(0.1, function()
						task.spawn(tab.Function, cfg[Table.Name].Toggles[tab.Name].Enabled)
					end)
				end

				return moduleHandler
			end

			function moduleHandler.CreatePicker(self, tab)
				local index = 1
				if not cfg[Table.Name].Dropdowns[tab.Name] then
					cfg[Table.Name].Dropdowns[tab.Name] = {Value = tab.Default or tab.Options[1]}
				end

				local PickerFrame = Instance.new('Frame')
				PickerFrame.Size = UDim2.new(1, 0, 0, 34)
				PickerFrame.BackgroundColor3 = lib.API.themes.Third[lib.API.themes.theme]
				PickerFrame.BorderSizePixel = 0
				PickerFrame.Parent = DropdownFrame

				cfg[Table.Name].Dropdowns[tab.Name].Inst = PickerFrame

				local PickerText = Instance.new('TextButton')
				PickerText.Position = UDim2.fromScale(0.05, 0)
				PickerText.Size = UDim2.fromScale(1, 1)
				PickerText.BackgroundTransparency = 1
				PickerText.TextXAlignment = Enum.TextXAlignment.Left
				PickerText.TextYAlignment = Enum.TextYAlignment.Center
				PickerText.TextColor3 = Color3.fromRGB(255, 255, 255)
				PickerText.TextSize = 10
				PickerText.Text = tab.Name
				PickerText.Parent = PickerFrame

				local OptionText = Instance.new('TextLabel')
				OptionText.Position = UDim2.fromScale(0.05, 0)
				OptionText.Size = UDim2.fromScale(0.9, 1)
				OptionText.BackgroundTransparency = 1
				OptionText.TextXAlignment = Enum.TextXAlignment.Right
				OptionText.TextYAlignment = Enum.TextYAlignment.Center
				OptionText.TextColor3 = Color3.fromRGB(255, 255, 255)
				OptionText.TextSize = 10
				OptionText.Text = cfg[Table.Name].Dropdowns[tab.Name].Value
				OptionText.Parent = PickerFrame

				local pickerHandler = {
					Value = cfg[Table.Name].Dropdowns[tab.Name].Value,
					Set = function(self, val)
						index = val

						self.Value = tab['Options'][index]
						OptionText.Text = tab['Options'][index]
						cfg[Table.Name].Dropdowns[tab.Name].Value = tab['Options'][index]

						if tab.Function then
							task.spawn(tab.Function, self.Value)
						end

						configSys:Save()
					end,
				}

				for i,v in tab.Options do
					if pickerHandler.Value == v then
						pickerHandler:Set(i)
					end
				end

				table.insert(lib.connections, PickerText.MouseButton1Down:Connect(function()
					index += 1
					if index > #tab.Options then
						index = 1
					end

					pickerHandler:Set(index)
				end))

				table.insert(lib.connections, PickerText.MouseButton2Down:Connect(function()
					index -= 1
					if index < 1 then
						index = #tab.Options
					end

					pickerHandler:Set(index)
				end))

				return pickerHandler
			end

			function moduleHandler.CreateSlider(self, tab)
				if not cfg[Table.Name].Sliders[tab.Name] then
					cfg[Table.Name].Sliders[tab.Name] = {Value = tab.Default or tab.Min}
				end

				local SliderFrame = Instance.new('Frame')
				SliderFrame.Size = UDim2.new(1, 0, 0, 34)
				SliderFrame.BackgroundColor3 = lib.API.themes.Third[lib.API.themes.theme]
				SliderFrame.BorderSizePixel = 0
				SliderFrame.Parent = DropdownFrame

				local isDragging = false
				cfg[Table.Name].Sliders[tab.Name].Inst = SliderFrame

				local SliderText = Instance.new('TextLabel')
				SliderText.AnchorPoint = Vector2.new(0.05, 0.06)
				SliderText.Position = UDim2.fromScale(0.05, 0.06)
				SliderText.Size = UDim2.new(0, 0, 0, 15)
				SliderText.BackgroundTransparency = 1
				SliderText.TextXAlignment = Enum.TextXAlignment.Left
				SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
				SliderText.TextSize = 10
				SliderText.Text = tab.Name
				SliderText.Parent = SliderFrame

				local ValueText = Instance.new('TextBox')
				ValueText.AnchorPoint = Vector2.new(0.95, 0.06)
				ValueText.Position = UDim2.fromScale(0.95, 0.06)
				ValueText.BackgroundTransparency = 1
				ValueText.TextXAlignment = Enum.TextXAlignment.Right
				ValueText.TextColor3 = Color3.fromRGB(255, 255, 255)
				ValueText.TextSize = 10
				ValueText.Text = string.format('%.2f', cfg[Table.Name].Sliders[tab.Name].Value)
				ValueText.Parent = SliderFrame

				local textSize = textService:GetTextSize(string.format('%.2f', cfg[Table.Name].Sliders[tab.Name].Value), ValueText.TextSize, ValueText.Font, Vector2.new(SliderFrame.AbsoluteSize.X, 1 / 0))
				ValueText.Size = UDim2.new(0, textSize.X, 0, 15)

				local SliderBackground = Instance.new('Frame')
				SliderBackground.AnchorPoint = Vector2.new(0.5, 0.8)
				SliderBackground.Position = UDim2.fromScale(0.5, 0.8)
				SliderBackground.Size = UDim2.new(0.9, 0, 0, 8)
				SliderBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				SliderBackground.BorderSizePixel = 0
				SliderBackground.Parent = SliderFrame

				local SliderFill = Instance.new('Frame')
				SliderFill.Size = UDim2.new(0, 0, 1, 0)
				SliderFill.BackgroundColor3 = lib.API.themes.Sliders[lib.API.themes.theme]
				SliderFill.BorderSizePixel = 0
				SliderFill.Parent = SliderBackground

				cfg[Table.Name].Sliders[tab.Name].FillInst = SliderFill

				local SliderButton = Instance.new('TextButton')
				SliderButton.Size = UDim2.new(1, 0, 1, 0)
				SliderButton.BackgroundTransparency = 1
				SliderButton.Text = ''
				SliderButton.ZIndex = 2
				SliderButton.Parent = SliderBackground

				local percent = (cfg[Table.Name].Sliders[tab.Name].Value - tab.Min) / (tab.Max - tab.Min)
				SliderFill.Size = UDim2.new(percent, 0, 1, 0)

				local moduleHandler = {
					Value = cfg[Table.Name].Sliders[tab.Name].Value,
					Min = tab.Min,
					Max = tab.Max,
					Set = function(self, value)
						value = math.clamp(value, self.Min, self.Max)
						if tab.Round then
							value = math.floor(value / tab.Round) * tab.Round
						end

						self.Value = value
						cfg[Table.Name].Sliders[tab.Name].Value = value

						SliderFill.Size = UDim2.new((value - self.Min) / (self.Max - self.Min), 0, 1, 0)

						local textSize = textService:GetTextSize(string.format('%.2f', cfg[Table.Name].Sliders[tab.Name].Value), ValueText.TextSize, ValueText.Font, Vector2.new(SliderFrame.AbsoluteSize.X, 1 / 0))
						ValueText.Size = UDim2.new(0, textSize.X, 0, 15)
						ValueText.Text = string.format('%.2f', value)

						if tab.Function then
							task.spawn(tab.Function, value)
						end

						configSys:Save()
					end
				}

				local function updateSlider(input)
					local X = math.clamp(((input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X), 0, 1)

					local value = tab.Min + (X * (tab.Max - tab.Min))
					moduleHandler:Set(value)
				end

				table.insert(lib.connections, SliderButton.MouseButton1Down:Connect(function()
					isDragging = true
				end))

				table.insert(lib.connections, SliderButton.MouseButton1Click:Connect(function()
					local mouse = inputService:GetMouseLocation()
					updateSlider({Position = Vector2.new(mouse.X, mouse.Y)})
				end))

				table.insert(lib.connections, ValueText.FocusLost:Connect(function(pressed)
					if not pressed then return end

					local numVal = tonumber(ValueText.Text)
					if numVal then
						local val = math.clamp(numVal, tab.Min, tab.Max)
						moduleHandler:Set(val)
					else
						ValueText.Text = string.format('%.2f', moduleHandler.Value)
					end
				end))

				table.insert(lib.connections, inputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						isDragging = false
					end
				end))

				table.insert(lib.connections, inputService.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
						updateSlider(input)
					end
				end))

				if tab.Function then
					task.spawn(tab.Function, moduleHandler.Value)
				end

				return moduleHandler
			end

			table.insert(lib.connections, ModuleText.MouseButton1Click:Connect(function()
				moduleHandler:Toggle()
			end))

			if cfg[Table.Name].Enabled and Table.Function then
				task.delay(0.1, function()
					task.spawn(Table.Function, cfg[Table.Name].Enabled)
				end)
			end

			table.insert(lib.connections, ModuleText.MouseButton2Down:Connect(function()
				DropdownFrame.Visible = not DropdownFrame.Visible
			end))

			local KeybindButton = Instance.new('Frame')
			KeybindButton.Size = UDim2.new(1, 0, 0, 34)
			KeybindButton.BorderSizePixel = 0
			KeybindButton.BackgroundColor3 = lib.API.themes.Third[lib.API.themes.theme]
			KeybindButton.Parent = DropdownFrame

			cfg[Table.Name].KeybindInst = KeybindButton

			local KeybindText = Instance.new('TextButton')
			KeybindText.Position = UDim2.fromScale(0.05, 0)
			KeybindText.Size = UDim2.fromScale(1, 1)
			KeybindText.BackgroundTransparency = 1
			KeybindText.TextXAlignment = Enum.TextXAlignment.Left
			KeybindText.TextColor3 = Color3.fromRGB(255, 255, 255)
			KeybindText.TextSize = 10.5
			KeybindText.Text = 'Keybind: '..cfg[Table.Name].Keybind
			KeybindText.Parent = KeybindButton

			table.insert(lib.connections, KeybindText.MouseButton1Click:Connect(function()
				local conn
				conn = inputService.InputBegan:Connect(function(key, gpe)
					if gpe then return end

					if key.KeyCode ~= Enum.KeyCode.Unknown and key.KeyCode ~= Enum.KeyCode.Backspace then
						cfg[Table.Name].Keybind = tostring(key.KeyCode):gsub('Enum.KeyCode.', '')
						KeybindText.Text = 'Keybind: '..cfg[Table.Name].Keybind

						conn:Disconnect()
					elseif key.KeyCode == Enum.KeyCode.Backspace then
						cfg[Table.Name].Keybind = 'Unknown'
						KeybindText.Text = 'Keybind: '..cfg[Table.Name].Keybind

						conn:Disconnect()
					end
				end)
			end))

			table.insert(lib.connections, inputService.InputBegan:Connect(function(key, gpe)
				if gpe then return end

				if key.KeyCode ~= Enum.KeyCode.Unknown and key.KeyCode == Enum.KeyCode[cfg[Table.Name].Keybind] then
					moduleHandler:Toggle()
				end
			end))

			self.Modules[Table.Name] = moduleHandler
			return moduleHandler
		end
	}

	return Windows[txt]
end

lib.API.Uninject = function()
	configSys.canSave = false

	for i,v in lib.connections do
		v:Disconnect()
	end

	for i,v in Windows do
		for x,d in v.Modules do
			if d.Enabled then
				d:Toggle()
			end
		end
	end

	ScreenGUI:Destroy()
	ArrayGUI:Destroy()
	lib = nil
end

return lib