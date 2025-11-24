repeat wait() until game:IsLoaded()
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/not-hm/MonsoonForRoblox/refs/heads/main/library.lua"))()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local BridgeDuel = {}

task.defer(function()
	local Knit = require(ReplicatedStorage.Modules.Knit.Client)
	repeat task.wait() until Knit.IsStarted
	BridgeDuel = {
		Knit = Knit,
		Blink = require(ReplicatedStorage.Blink.Client),
		Entity = require(ReplicatedStorage.Modules.Entity),
		ServerData = require(ReplicatedStorage.Modules.ServerData),
		Constant = {
			Rank = require(ReplicatedStorage.Constants.Ranks),
			Melee = require(ReplicatedStorage.Constants.Melee),
			Block = require(ReplicatedStorage.Constants.Blocks),
			Ranged = require(ReplicatedStorage.Constants.Ranged),
			Pickaxe = require(ReplicatedStorage.Constants.Pickaxes),
			Blocks = {
				Names = {"Blocks", "WoodPlanksBlock", "StoneBlock", "IronBlock", "BricksBlocks", "DiamondBlock"},
				Types = {
					Blocks = "Clay",
					WoodPlanksBlock = "WoodPlanks",
					StoneBlock = "Stone",
					IronBlock = "Iron",
					BricksBlocks = "Bricks",
					DiamondBlock = "Diamond"
				}
			}
		}
	}
end)

repeat task.wait() until BridgeDuel.Knit and BridgeDuel.Blink and BridgeDuel.Entity and BridgeDuel.Constant and BridgeDuel.Constant.Rank and BridgeDuel.Constant.Melee and BridgeDuel.Constant.Ranged and BridgeDuel.Constant.Pickaxe
local MainFrame = Library:CreateMain()
local TabSections = {
	Combat = MainFrame:CreateTab("1"),
	Exploit = MainFrame:CreateTab("2"),
	Move = MainFrame:CreateTab("3"),
	Player = MainFrame:CreateTab("4"),
	Visual = MainFrame:CreateTab("5"),
	World = MainFrame:CreateTab("6"),
	Manager = MainFrame:CreateManager()
}

local function IsAlive(v)
	return v and v.PrimaryPart and v:FindFirstChildOfClass("Humanoid") and v:FindFirstChildOfClass("Humanoid").Health > 0
end

local function CheckForWall(v)
	local Raycast = RaycastParams.new()
	Raycast.FilterType = Enum.RaycastFilterType.Exclude
	Raycast.FilterDescendantsInstances = {LocalPlayer.Character}
	local Direction = v.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position
	local Result = workspace:Raycast(LocalPlayer.Character.PrimaryPart.Position, Direction, Raycast)
	if Result and Result.Instance and not v:IsAncestorOf(Result.Instance) then
		return false
	end
	return true
end

local function GetNearestEntity(MaxDist, EntityCheck, EntitySort, EntityTeam, EntityWall, EntityDirection)
	local Entity
	local MinDist = math.huge
	for _, v in pairs(workspace:GetChildren()) do
		if v:IsA("Model") and v.Name ~= LocalPlayer.Name and IsAlive(v) then
			local IsEntity = false
			if not EntityCheck then
				if not EntityWall or CheckForWall(v) then
					IsEntity = true
				end
			else
				for _, plr in pairs(Players:GetPlayers()) do
					if plr.Name == v.Name and (not EntityTeam or plr.TeamColor ~= LocalPlayer.TeamColor) then
						if not EntityWall or CheckForWall(v) then
							IsEntity = true
						end
					end
				end
			end
			if IsEntity then
				local Direction = (v.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Unit
				local Angle = math.deg(LocalPlayer.Character.PrimaryPart.CFrame.LookVector:Angle(Direction))
				if EntityDirection >= 360 or Angle <= EntityDirection / 2 then
					local Distance = (v.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
					if EntitySort == "Distance" and Distance <= MaxDist and (not MinDist or Distance < MinDist) then
						MinDist = Distance
						Entity = v
					elseif EntitySort == "Furthest" and Distance <= MaxDist and (not MinDist or Distance > MinDist) then
						MinDist = Distance
						Entity = v
					elseif EntitySort == "Health" and Distance <= MaxDist and v:FindFirstChild("Humanoid") and (not MinDist or v.Humanoid.Health < MinDist) then
						MinDist = v.Humanoid.Health
						Entity = v
					elseif EntitySort == "Threat" and Distance <= MaxDist and v:FindFirstChild("Humanoid") and (not MinDist or v.Humanoid.Health > MinDist) then
						MinDist = v.Humanoid.Health
						Entity = v
					end
				end
			end
		end
	end
	return Entity
end

local function GetBed(MaxDist)
	local Bed
	local MinDist = math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v.Parent:IsA("Model") and v.Parent.Name == "Bed" and v.Name == "Block" and v.Parent:GetAttribute("Team") ~= LocalPlayer.Team.Name then
			local Distance = (v.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
			if Distance < MinDist and Distance <= MaxDist then
				MinDist = Distance
				Bed = v
			end
		end
	end
	return Bed
end

local function GetPosition(pos)
	return Vector3.new(math.floor((pos.X / 3) + 0.5) * 3,math.floor((pos.Y / 3) + 0.5) * 3,math.floor((pos.Z / 3) + 0.5) * 3)
end

local function IsAtPosition(pos)
	for _, v in pairs(workspace:WaitForChild("Map"):GetDescendants()) do
		if v:IsA("BasePart") and v.Name == "Block" then
			if GetPosition(v.Position) == pos then
				return true
			end
		end
	end
	return false
end

local function GetBlocks()
	local Prioritized = {"Clay", "Bricks", "WoodPlanks", "Stone", "Iron", "Diamond"}
	local Stored = {}
	for _, storage in ipairs({LocalPlayer.Backpack, LocalPlayer.Character}) do
		for _, block in ipairs(storage:GetChildren()) do
			if table.find(BridgeDuel.Constant.Blocks.Names, block.Name) then
				local BlockType = BridgeDuel.Constant.Blocks.Types[block.Name]
				if BlockType and not Stored[BlockType] then
					local Inventory = BridgeDuel.Entity.LocalEntity.Inventory
					if Inventory and Inventory[block.Name] and Inventory[block.Name] > 0 then
						Stored[BlockType] = block
					end
				end
			end
		end
	end
	for _, v in ipairs(Prioritized) do
		if Stored[v] then
			return Stored[v], v
		end
	end
	return nil, nil
end

local function GetTool(toolname)
	for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
		if v:IsA("Tool") and v.Name:lower():match(toolname) then
			return v
		end
	end
end

local function CheckTool(toolname)
	for _, v in pairs(LocalPlayer.Character:GetChildren()) do
		if v:IsA("Tool") and v.Name:lower():match(toolname) then
			return v
		end
	end
end

local AntiBot
task.defer(function()
	AntiBot = TabSections.Combat:CreateToggle({
		Name = "Anti Bot",
		Callback = function(callback)
		end
	})
end)

local AutoClicker
task.defer(function()
	if Library.DeviceType == "Mouse" then
		local MaxCPS, MinCPS, CCPS = nil, nil, nil
		local RandomCPS, CDelay = false, nil
		AutoClicker = TabSections.Combat:CreateToggle({
			Name = "Auto Clicker",
			Callback = function(callback)
				if callback then
					task.spawn(function()
						repeat
							if IsAlive(LocalPlayer.Character) then
								local Tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
								if RandomCPS then
									CCPS = math.random(MinCPS, MaxCPS)
								else
									CCPS = MaxCPS
								end
								if CCPS ~= nil then
									CDelay = 1 / CCPS
								end
								if Tool and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
									Tool:Activate()
								end
							end
							task.wait(CDelay or 0.1)
						until not AutoClicker.Enabled
					end)
				end
			end
		})
		local AutoClickRandom = AutoClicker:CreateMiniToggle({
			Name = "Randomize",
			Callback = function(callback)
				if callback then
					RandomCPS = true
				else
					RandomCPS = false
				end
			end
		})
		local AutoClickerMax = AutoClicker:CreateSlider({
			Name = "Max",
			Min = 0,
			Max = 20,
			Default = 10,
			Callback = function(callback)
				if callback then
					MaxCPS = callback
				end
			end
		})
		local AutoClickerMin = AutoClicker:CreateSlider({
			Name = "Min",
			Min = 0,
			Max = 20,
			Default = 8,
			Callback = function(callback)
				if callback then
					MinCPS = callback
				end
			end
		})
	end
end)

local Criticals
task.defer(function()
	local original
	Criticals = TabSections.Combat:CreateToggle({
		Name = "Criticals",
		Callback = function(callback)
			repeat task.wait() until BridgeDuel.Blink.item_action.attack_entity.fire
			if callback then
				original = hookfunction(BridgeDuel.Blink.item_action.attack_entity.fire, function(...)
					local args = ...
					if type(args) == "table" and args["is_crit"] ~= 1 then
						args["is_crit"] = 1
					end
					return original(args)
				end)
			else
				if original then
					hookfunction(BridgeDuel.Blink.item_action.attack_entity.fire, original)
					original = nil
				end
			end
		end
	})
end)

local Hitbox
task.defer(function()
	local Size = {X = 2.4, Y = 5, Z = 2.4}
	Hitbox = TabSections.Combat:CreateToggle({
		Name = "Hitbox",
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						for _, plr in pairs(Players:GetPlayers()) do
							if plr ~= LocalPlayer and IsAlive(plr.Character) then
								local Hitbox = plr.Character:FindFirstChild("Hitbox")
								if Hitbox and Hitbox.Size ~= Vector3.new(Size.X, Size.Y, Size.Z) then
									Hitbox.Size = Vector3.new(Size.X, Size.Y, Size.Z)
								end
							end
						end
						task.wait(2)
					until not Hitbox.Enabled
					for _, plr in pairs(Players:GetPlayers()) do
						if plr ~= LocalPlayer and IsAlive(plr.Character) then
							local Hitbox = plr.Character:FindFirstChild("Hitbox")
							if Hitbox and Hitbox.Size ~= Vector3.new(2.4, 5, 2.4) then
								Hitbox.Size = Vector3.new(2.4, 5, 2.4)
							end
						end
					end
				end)
			end
		end
	})
	local HitboxSizeX = Hitbox:CreateSlider({
		Name = "X",
		Min = 0,
		Max = 16,
		Default = 2.4,
		Callback = function(callback)
			if callback then
				Size.X = callback
			end
		end
	})
	local HitboxSizeY = Hitbox:CreateSlider({
		Name = "Y",
		Min = 0,
		Max = 16,
		Default = 5,
		Callback = function(callback)
			if callback then
				Size.Y = callback
			end
		end
	})
	local HitboxSizeZ = Hitbox:CreateSlider({
		Name = "Z",
		Min = 0,
		Max = 16,
		Default = 2.4,
		Callback = function(callback)
			if callback then
				Size.Z = callback
			end
		end
	})
end)

local KillAura
local EntityCFrame
local KillAuraEntity
task.defer(function()
	local WallCheck, TeamCheck, SortType, ADirection = true, false, nil, nil
	local Distance, ADelay, AType = nil, nil, "Blatant"
	local CanSwing, CanBlock = false, false
	local LocalEntity
	local SwingAnim
	local Sword
	KillAura = TabSections.Combat:CreateToggle({
		Name = "Kill Aura",
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						if AType == "Blatant" then
							ADelay = 0.01
						elseif AType == "Legit" then
							ADelay = 0.2
						end
						if IsAlive(LocalPlayer.Character) then
							local Entity = GetNearestEntity(Distance, AntiBot.Enabled, SortType, TeamCheck, WallCheck, ADirection)
							if Entity and Entity.PrimaryPart then
								KillAuraEntity = Entity
								EntityCFrame = CFrame.lookAt(LocalPlayer.Character.PrimaryPart.Position, Vector3.new(Entity.PrimaryPart.Position.X, LocalPlayer.Character.PrimaryPart.Position.Y, Entity.PrimaryPart.Position.Z))
								Sword = CheckTool("sword") or GetTool("sword")
								if Sword then
									if not SwingAnim then
										SwingAnim = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):LoadAnimation(Sword:WaitForChild("Animations"):FindFirstChild("Swing"))
										SwingAnim.Looped = true
									end
									if LocalEntity then
										if CanBlock and not LocalEntity.IsBlocking then
											BridgeDuel.Knit.GetController("ViewmodelController"):ToggleLoopedAnimation(Sword.Name, true)
											BridgeDuel.Knit.GetService("ToolService"):ToggleBlockSword(true, Sword.Name)
										end
									else
										LocalEntity = BridgeDuel.Entity.LocalEntity
									end
									if CanSwing and not SwingAnim.IsPlaying and (not CanBlock and not LocalEntity.IsBlocking) then
										SwingAnim:Play()
									end
									if BridgeDuel and BridgeDuel.Entity and BridgeDuel.Blink and BridgeDuel.Knit then
										local TargetEntity = BridgeDuel.Entity.FindByCharacter(Entity)
										if TargetEntity and TargetEntity.Id then
											BridgeDuel.Blink.item_action.attack_entity.fire({
												target_entity_id = TargetEntity.Id,
												is_crit = LocalPlayer.Character.PrimaryPart.AssemblyLinearVelocity.Y < 0,
												weapon_name = Sword.Name,
												extra = {
													rizz = "Bro.",
													sigma = "The...",
													those = workspace.Name == "Ok"
												}
											})
										end
										BridgeDuel.Knit.GetService("ToolService"):AttackPlayerWithSword(Entity, LocalPlayer.Character.PrimaryPart.AssemblyLinearVelocity.Y < 0, Sword.Name, "\226\128\139")
										if CanSwing and (not CanBlock and not LocalEntity.IsBlocking) then
											BridgeDuel.Knit.GetController("ViewmodelController"):PlayAnimation(Sword.Name)
										end
									end
								else
									if SwingAnim and SwingAnim.IsPlaying then
										SwingAnim:Stop()
									end
								end
							else
								EntityCFrame = nil
								KillAuraEntity = nil
								if LocalEntity and LocalEntity.IsBlocking then
									BridgeDuel.Knit.GetController("ViewmodelController"):ToggleLoopedAnimation(Sword.Name, false)
									BridgeDuel.Knit.GetService("ToolService"):ToggleBlockSword(false, Sword.Name)
								end
								if SwingAnim and SwingAnim.IsPlaying then
									SwingAnim:Stop()
								end
							end
						end
						task.wait(ADelay)
					until not KillAura.Enabled
					EntityCFrame = nil
					KillAuraEntity = nil
					if LocalEntity and LocalEntity.IsBlocking then
						BridgeDuel.Knit.GetController("ViewmodelController"):ToggleLoopedAnimation(Sword.Name, false)
						BridgeDuel.Knit.GetService("ToolService"):ToggleBlockSword(false, Sword.Name)
					end
					if SwingAnim and SwingAnim.IsPlaying then
						SwingAnim:Stop()
					end
				end)
			end
		end
	})
	local KillAuraType = KillAura:CreateDropdown({
		Name = "Kill_Aura_Type",
		List = {"Legit", "Blatant"},
		Default = "Blatant",
		Callback = function(callback)
			if callback then
				AType = callback
			end
		end
	})
	local KillAuraSort = KillAura:CreateDropdown({
		Name = "Kill_Aura_Sort",
		List = {"Furthest", "Health", "Threat", "Distance"},
		Default = "Distance",
		Callback = function(callback)
			if callback then
				SortType = callback
			end
		end
	})
	local KillAuraDirection = KillAura:CreateSlider({
		Name = "Direction",
		Min = 0,
		Max = 360,
		Default = 360,
		Callback = function(callback)
			if callback then
				ADirection = callback
			end
		end
	})
	local KillAuraDistance = KillAura:CreateSlider({
		Name = "Distance",
		Min = 0,
		Max = 22,
		Default = 20,
		Callback = function(callback)
			if callback then
				Distance = callback
			end
		end
	})
	local KillAuraBlock = KillAura:CreateMiniToggle({
		Name = "Auto Block",
		Callback = function(callback)
			if callback then
				CanBlock = true
			else
				CanBlock = false
			end
		end
	})
	local KillAuraWall = KillAura:CreateMiniToggle({
		Name = "Through Walls",
		Callback = function(callback)
			if callback then
				WallCheck = false
			else
				WallCheck = true
			end
		end
	})
	local KillAuraSwing = KillAura:CreateMiniToggle({
		Name = "Swing",
		Callback = function(callback)
			if callback then
				CanSwing = true
			else
				CanSwing = false
			end
		end
	})
	local KillAuraTeam = KillAura:CreateMiniToggle({
		Name = "Team",
		Callback = function(callback)
			if callback then
				TeamCheck = true
			else
				TeamCheck = false
			end
		end
	})
end)

local Velocity
task.defer(function()
	local connections
	Velocity = TabSections.Combat:CreateToggle({
		Name = "Velocity",
		Callback = function(callback)
			local Connection = BridgeDuel.Knit.GetService("CombatService").KnockBackApplied._re
			repeat task.wait() until Connection and Connection.OnClientEvent
			if callback then
				connections = getconnections(Connection.OnClientEvent)[1]
				if connections and connections.Function then
					connections:Disable()
				end
			else
				if connections and connections.Function then
					connections:Enable()
					connections = nil
				end
			end
		end
	})
end)

local NoFallDamage
local AngryBird
task.defer(function()
	AngryBird = TabSections.Exploit:CreateToggle({
		Name = "AngryBird",
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if not NoFallDamage.Enabled then
							BridgeDuel.Blink.player_state.take_fall_damage.fire(0)
						end
					until not AngryBird.Enabled
				end)
			end
		end
	})
end)

local AntiStaff
task.defer(function()
	local AutoLeave = false
	local InServer = {}
	AntiStaff = TabSections.Exploit:CreateToggle({
		Name = "Anti Staff",
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						for _, v in pairs(Players:GetPlayers()) do
							for _, r in ipairs(BridgeDuel.Constant.Rank) do
								if r.Name == "Admin" then
									for _, id in ipairs(r.Users) do
										if v.UserId == id then
											if not table.find(InServer, v.Name) then
												StarterGui:SetCore("SendNotification", {
													Title = "Anti Staff",
													Text = "Staff detected: " .. v.Name,
													Icon = "rbxassetid://6747907729",
													Duration = 15,
												})
												table.insert(InServer, v.Name)
												if AutoLeave then
													task.wait(2.5)
													TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync("/lobby")
												end
											end
										end
									end
								end
							end
						end
						for i = #InServer, 1, -1 do
							local InGame = false
							for _, v in pairs(Players:GetPlayers()) do
								if v.Name == InServer[i] then
									InGame = true
									break
								end
							end
							if not InGame then
								StarterGui:SetCore("SendNotification", {
									Title = "Anti Staff",
									Text = "Staff left: " .. InServer[i],
									Icon = "rbxassetid://6747907729",
									Duration = 10,
								})
								table.remove(InServer, i)
							end
						end
					until not AntiStaff.Enabled
					table.clear(InServer)
				end)
			end
		end
	})
	local ASALeave = AntiStaff:CreateMiniToggle({
		Name = "Auto Leave",
		Callback = function(callback)
			if callback then
				AutoLeave = true
			else
				AutoLeave = false
			end
		end
	})
end)

local DeviceChanger
task.defer(function()
	local Selected
	DeviceChanger = TabSections.Exploit:CreateToggle({
		Name = "Device Changer",
		AutoDisable = true,
		Callback = function(callback)
			if callback then
				if Selected == "Gamepad" then
					LocalPlayer.PlayerGui.TabList.TabList.Middle[LocalPlayer.Name].DeviceComputer.Visible = false
					LocalPlayer.PlayerGui.TabList.TabList.Middle[LocalPlayer.Name].DeviceGamepad.Visible = true
					LocalPlayer.PlayerGui.TabList.TabList.Middle[LocalPlayer.Name].DeviceMobile.Visible = false
				elseif Selected == "Mobile" then
					LocalPlayer.PlayerGui.TabList.TabList.Middle[LocalPlayer.Name].DeviceComputer.Visible = false
					LocalPlayer.PlayerGui.TabList.TabList.Middle[LocalPlayer.Name].DeviceGamepad.Visible = false
					LocalPlayer.PlayerGui.TabList.TabList.Middle[LocalPlayer.Name].DeviceMobile.Visible = true		
				elseif Selected == "Computer" then
					LocalPlayer.PlayerGui.TabList.TabList.Middle[LocalPlayer.Name].DeviceComputer.Visible = true
					LocalPlayer.PlayerGui.TabList.TabList.Middle[LocalPlayer.Name].DeviceGamepad.Visible = false
					LocalPlayer.PlayerGui.TabList.TabList.Middle[LocalPlayer.Name].DeviceMobile.Visible = false
				end
				BridgeDuel.Blink.player_state.device_type_changed.fire(Selected)
			end
		end
	})
	local DeviceType = DeviceChanger:CreateDropdown({
		Name = "Device_Type",
		List = {"Gamepad", "Mobile", "Computer"},
		Default = "Computer",
		Callback = function(callback)
			if callback then
				Selected = callback
			end
		end
	})
end)

local MassReport
task.defer(function()
	local Reported = {}
	MassReport = TabSections.Exploit:CreateToggle({
		Name = "Mass Report",
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait(2)
						for _, plr in ipairs(Players:GetPlayers()) do
							if not table.find(Reported, plr.Name) then
								table.insert(Reported, plr.Name)
								BridgeDuel.Knit.GetService("NetworkService"):ReportPlayer(plr)
							end
						end
					until not MassReport.Enabled
				end)
			end
		end
	})
end)

local Flight
task.defer(function()
	local OldGravity = workspace.Gravity
	local NewY, OldY
	local Speed
	Flight = TabSections.Move:CreateToggle({
		Name = "Flight",
		Callback = function(callback)
			if callback then
				NewY = 0
				OldY = LocalPlayer.Character.PrimaryPart.Position.Y
				task.spawn(function()
					repeat
						task.wait()
						if IsAlive(LocalPlayer.Character) then
							if workspace.Gravity ~= 0 then
								workspace.Gravity = 0
							end
							local MoveDirection = LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection
							LocalPlayer.Character.PrimaryPart.Velocity = Vector3.new(MoveDirection.X * Speed, LocalPlayer.Character.PrimaryPart.Velocity.Y, MoveDirection.Z * Speed)
							LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(LocalPlayer.Character.PrimaryPart.Position.X, OldY + NewY, LocalPlayer.Character.PrimaryPart.Position.Z) * LocalPlayer.Character.PrimaryPart.CFrame.Rotation
							if UserInputService:IsKeyDown("Space") and not UserInputService:GetFocusedTextBox() then
								NewY += 0.8
							elseif UserInputService:IsKeyDown("LeftShift") and not UserInputService:GetFocusedTextBox() then
								NewY -= 0.8
							end
							if Library.DeviceType == "Touch" then
								if  LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Jump then
									NewY += 0.8
								end
								local LocalEntity = BridgeDuel.Entity.LocalEntity
								if LocalEntity and LocalEntity.IsSneaking then
									NewY -= 0.8
								end
							end
						end
					until not Flight.Enabled
					LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(LocalPlayer.Character.PrimaryPart.Position)
					OldY = LocalPlayer.Character.PrimaryPart.Position.Y
					workspace.Gravity = OldGravity
				end)
			end
		end
	})
	local FlightSpeed = Flight:CreateSlider({
		Name = "Speed",
		Min = 0,
		Max = 150,
		Default = 28,
		Callback = function(callback)
			if callback then
				Speed = callback
			end
		end
	})
end)

local LongJump
task.defer(function()
	local OldGravity = workspace.Gravity
	local IsJumping = false
	local Counters
	LongJump = TabSections.Move:CreateToggle({
		Name = "Long Jump",
		AutoDisable = true,
		Callback = function(callback)
			if callback then
				local Counters = 0
				task.spawn(function()
					IsJumping = true
					task.wait(3.5)
					IsJumping = false
				end)
				task.spawn(function()
					repeat
						if IsAlive(LocalPlayer.Character) then
							task.wait(0.1)
							if workspace.Gravity ~= 0 then
								workspace.Gravity = 0
							end
							local Direction = LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection
							LocalPlayer.Character.PrimaryPart.CFrame = LocalPlayer.Character.PrimaryPart.CFrame + (Direction * 28 * 0.15)
							Counters += 1
							if Counters >= 12 then
								break 
							end
						end
					until not IsJumping
					workspace.Gravity = OldGravity
				end)
			end
		end
	})
end)

local NoSlowDown
task.defer(function()
	local Signal
	NoSlowDown = TabSections.Move:CreateToggle({
		Name = "No Slow Down",
		Callback = function(callback)
			if callback then
				LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
				Signal = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):GetPropertyChangedSignal("WalkSpeed"):Connect(function()
					if IsAlive(LocalPlayer.Character) then
						if LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed ~= 16 then
							LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
						end
					end
				end)
			else
				if Signal then
					Signal:Disconnect()
					Signal = nil
				end
				LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
			end
		end
	})
end)

local Speed
task.defer(function()
	local AutoJump = false
	local Speeds
	Speed = TabSections.Move:CreateToggle({
		Name = "Speed",
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if not Flight.Enabled and IsAlive(LocalPlayer.Character) and LocalPlayer.Character.PrimaryPart then
							local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
							local MoveDirection = Humanoid.MoveDirection
							LocalPlayer.Character.PrimaryPart.Velocity = Vector3.new(MoveDirection.X * Speeds, LocalPlayer.Character.PrimaryPart.Velocity.Y, MoveDirection.Z * Speeds)
							if AutoJump and Humanoid.FloorMaterial ~= Enum.Material.Air and not Humanoid.Jump then
								Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
							end
						end
					until not Speed.Enabled
				end)
			end
		end
	})
	local SpeedAutoJump = Speed:CreateMiniToggle({
		Name = "Auto Jump",
		Callback = function(callback)
			if callback then
				AutoJump = true
			else
				AutoJump = false
			end
		end
	})
	local SpeedValue = Speed:CreateSlider({
		Name = "Speeds",
		Min = 0,
		Max = 150, 
		Default = 28,
		Callback = function(callback)
			if callback then
				Speeds = callback
			end
		end
	})
end)

local Step
task.defer(function()
	local Excluded = {}
	local Raycast = RaycastParams.new() 
	for _,plr in pairs(workspace:GetDescendants()) do
		if plr:IsA("Model") and IsAlive(plr) and not table.find(Excluded,plr) then
			table.insert(Excluded,plr)
		end
	end
	Raycast.FilterType = Enum.RaycastFilterType.Exclude
	Raycast.FilterDescendantsInstances = Excluded
	Step = TabSections.Move:CreateToggle({
		Name = "Step",
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if IsAlive(LocalPlayer.Character) then
							local Direction = LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection * 1.8
							if Direction.Magnitude > 0 then
								local Result = workspace:Raycast(LocalPlayer.Character.PrimaryPart.Position, Direction, Raycast)
								if Result and Result.Instance then
									LocalPlayer.Character.PrimaryPart.Velocity = Vector3.new(LocalPlayer.Character.PrimaryPart.Velocity.X,28,LocalPlayer.Character.PrimaryPart.Velocity.Z)
								end
							end
						end
					until not Step.Enabled
				end)
			end
		end
	})
end)

local Chams
task.defer(function()
	local function Highlight(v)
		if not v:FindFirstChildWhichIsA("Highlight") then
			local Highlight = Instance.new("Highlight")
			Highlight.FillTransparency = 1
			Highlight.OutlineTransparency = 0.45
			Highlight.OutlineColor = Color3.new(1,1,1)
			Highlight.Parent = v
		end
	end
	local function RemoveHighlight(v)
		local Highlight = v:FindFirstChildWhichIsA("Highlight")
		if Highlight then
			Highlight:Destroy()
		end
	end
	Chams = TabSections.Visual:CreateToggle({
		Name = "Chams",
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						for _,v in pairs(workspace:GetChildren()) do
							if v:IsA("Model") and IsAlive(v) and v.Name ~= LocalPlayer.Name then
								if not AntiBot.Enabled or Players:FindFirstChild(v.Name) then
									Highlight(v)
								else
									RemoveHighlight(v)
								end
							end
						end
					until not Chams.Enabled
					for _,v in pairs(workspace:GetChildren()) do
						if v:IsA("Model") and IsAlive(v) and v.Name ~= LocalPlayer.Name then
							RemoveHighlight(v)
						end
					end
				end)
			end
		end
	})
end)

local ClickGUI
task.defer(function()
	ClickGUI = TabSections.Visual:CreateToggle({
		Name = "ClickGUI",
		AutoDisable = true,
		Callback = function(callback)
		end
	})
	local QuitLime = ClickGUI:CreateMiniToggle({
		Name = "Quit",
		Callback = function(callback)
			if callback then
				Library.Uninject = true
			end
		end
	})
end)

local ESP
task.defer(function()
	local function AddBoxes(v)
		if not v:FindFirstChildWhichIsA("BillboardGui") then
			local Frame, UIStoke = nil, nil
			local BillboardGui = Instance.new("BillboardGui")
			BillboardGui.Parent = v
			BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			BillboardGui.Active = true
			BillboardGui.AlwaysOnTop = true
			BillboardGui.LightInfluence = 1.000
			BillboardGui.Size = UDim2.new(4.5,0,6.5,0)
			if BillboardGui and not BillboardGui:FindFirstChildWhichIsA("Frame") then
				Frame = Instance.new("Frame")
				Frame.Parent = BillboardGui
				Frame.AnchorPoint = Vector2.new(0.5,0.5)
				Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Frame.BackgroundTransparency = 1.000
				Frame.BorderColor3 = Color3.fromRGB(0,0,0)
				Frame.Position = UDim2.new(0.5,0,0.5,0)
				Frame.Size = UDim2.new(0.949999988,0,0.949999988,0)
				if Frame and not Frame:FindFirstChildWhichIsA("UIStroke") then
					UIStoke = Instance.new("UIStroke")
					UIStoke.Parent = Frame
					UIStoke.Color = Color3.fromRGB(255,255,255)
					UIStoke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
					UIStoke.LineJoinMode = Enum.LineJoinMode.Miter
					UIStoke.Thickness = 2
					UIStoke.Transparency = 0
				end
			end
		end
	end
	local function RemoveBoxes(v)
		local BillboardGui = v:FindFirstChildWhichIsA("BillboardGui")
		if BillboardGui then
			BillboardGui:Destroy()
		end
	end
	ESP = TabSections.Visual:CreateToggle({
		Name = "ESP",
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						for _,v in pairs(workspace:GetChildren()) do
							if v:IsA("Model") and IsAlive(v) and v.Name ~= LocalPlayer.Name then
								if not AntiBot.Enabled or Players:FindFirstChild(v.Name) then
									AddBoxes(v)
								else
									RemoveBoxes(v)
								end
							end
						end
					until not ESP.Enabled
					for _,v in pairs(workspace:GetChildren()) do
						if v:IsA("Model") and IsAlive(v) and v.Name ~= LocalPlayer.Name then
							RemoveBoxes(v)
						end
					end
				end)
			end
		end
	})
end)

local Fullbright
task.defer(function()
	local OldBrightness = Lighting.Brightness
	local OldAmbient = Lighting.Ambient
	local Signal1, Signal2
	Fullbright = TabSections.Visual:CreateToggle({
		Name = "Fullbright",
		Callback = function(callback)
			if callback then
				Lighting.Brightness = 5
				Lighting.Ambient = Color3.fromRGB(255, 255, 255)
				Signal1 = Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
					Lighting.Brightness = 5
				end)
				Signal2 = Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
					Lighting.Ambient = Color3.fromRGB(255, 255, 255)
				end)
			else
				if Signal1 and Signal2 then
					Signal1:Disconnect()
					Signal1 = nil
					Signal2:Disconnect()
					Signal2 = nil
				end
				Lighting.Brightness = OldBrightness
				Lighting.Ambient = OldAmbient
			end
		end
	}) 
end)

local HUD
task.defer(function()
	local IsArray, IsWatermark = false, false
	HUD = TabSections.Visual:CreateToggle({
		Name = "HUD",
		Enabled = true,
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if not Library.Visual.Hud then
							Library.Visual.Hud = true
						end
						if IsArray then
							Library.Visual.Arraylist = IsArray
						else
							Library.Visual.Arraylist = false
						end
						if IsWatermark then
							Library.Visual.Watermark = true
						else
							Library.Visual.Watermark = false
						end
					until not HUD.Enabled
					Library.Visual.Hud = false
				end)
			end
		end
	})
	local HArraylist = HUD:CreateMiniToggle({
		Name = "Arraylist",
		Enabled = true,
		Callback = function(callback)
			if callback then
				IsArray = true
			else
				IsArray = false
			end
		end
	})
	local HWatermark = HUD:CreateMiniToggle({
		Name = "Watermark",
		Enabled = true,
		Callback = function(callback)
			if callback then
				IsWatermark = true
			else
				IsWatermark = false
			end
		end
	})
end)

local KillEffects
task.defer(function()
	local IsDead, IsAlive
	local Effects = {}
	local Connection
	local Selected
	local Signal
	for _, v in pairs(ReplicatedStorage:WaitForChild("Assets"):WaitForChild("KillEffects"):GetChildren()) do
		if v:IsA("ModuleScript") and not table.find(Effects, v.Name) then
			table.insert(Effects, v.Name)
		end
	end
	KillEffects = TabSections.Visual:CreateToggle({
		Name = "Kill Effects",
		Callback = function(callback)
			Connection = BridgeDuel.Knit.GetService("CombatService").OnKill._re
			repeat task.wait() until Connection and Connection.OnClientEvent
			if callback then
				Signal = Connection.OnClientEvent:Connect(function(table1, table2)
					if type(table1) == "table" and type(table2) == "table" then
						if table1.Id then
							for _, killer in pairs(Players:GetPlayers()) do
								local Entity1 = BridgeDuel.Entity.FindByName(killer.Name)
								if Entity1 and Entity1.Id == table1.Id then
									IsAlive = killer
								end
							end
						end
						if table2.Id then
							for _, killed in pairs(Players:GetPlayers()) do
								local Entity2 = BridgeDuel.Entity.FindByName(killed.Name)
								if Entity2 and Entity2.Id == table2.Id then
									IsDead = killed
								end
							end
						end
					end
					if IsAlive and IsAlive.Name == LocalPlayer.Name and IsDead and IsDead.Name ~= LocalPlayer.Name then
						for _, v in pairs(ReplicatedStorage.Assets.KillEffects:GetChildren()) do
							if v:IsA("ModuleScript") and v.Name == Selected then
								require(v)(IsDead.Character.PrimaryPart.Position)
							end
						end
					end
				end)
			else
				if Signal then
					Signal:Disconnect()
					Signal = nil
				end
			end
		end
	})
	local KillEffectsType = KillEffects:CreateDropdown({
		Name = "KillEffects_Type",
		List = Effects,
		Default = "LightningKillEffect",
		Callback = function(callback)
			if callback then
				Selected = callback
			end
		end
	})
end)

local TargetHUD
task.defer(function()
	local TargetIcon
	TargetHUD = TabSections.Visual:CreateToggle({
		Name = "Target HUD",
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if KillAura.Enabled then
							if KillAuraEntity then
								local LocalTarget = Players:GetPlayerFromCharacter(KillAuraEntity)
								if LocalTarget then
									TargetIcon = Players:GetUserThumbnailAsync(LocalTarget.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size48x48)
								else
									TargetIcon = "rbxassetid://14025674892"
								end
								MainFrame:CreateTargetHUD(KillAuraEntity.Name, TargetIcon, KillAuraEntity:FindFirstChildOfClass("Humanoid"), true)
							else
								MainFrame:CreateTargetHUD(LocalPlayer.Name, Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48), LocalPlayer.Character:FindFirstChildOfClass("Humanoid"), true)
							end
						else
							MainFrame:CreateTargetHUD(LocalPlayer.Name, Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48), LocalPlayer.Character:FindFirstChildOfClass("Humanoid"), true)
						end
					until not TargetHUD.Enabled
					MainFrame:CreateTargetHUD(LocalPlayer.Name, Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48), LocalPlayer.Character:FindFirstChildOfClass("Humanoid"), false)
				end)
			end
		end
	})
end)

local Tracers
task.defer(function()
	local Lines = {}
	local function UpdatePos(v)
		if IsAlive(v) then
			local Vector, OnScreen = workspace.CurrentCamera:WorldToScreenPoint(v.PrimaryPart.Position)
			if OnScreen then
				local Origin = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2.3)
				local Destination = Vector2.new(Vector.X, Vector.Y)
				if not Lines[v] then
					Lines[v] = MainFrame:CreateLine(Origin, Destination)
				else
					local Line = Lines[v]
					Line.Position = UDim2.new(0, (Origin + Destination).X / 2, 0, (Origin + Destination).Y / 2)
					Line.Size = UDim2.new(0, (Origin - Destination).Magnitude, 0, 0.02)
					Line.Rotation = math.deg(math.atan2(Destination.Y - Origin.Y, Destination.X - Origin.X))
				end
			else
				if Lines[v] then
					Lines[v]:Destroy()
					Lines[v] = nil
				end
			end
		else
			if Lines[v] then
				Lines[v]:Destroy()
				Lines[v] = nil
			end
		end
	end
	Tracers = TabSections.Visual:CreateToggle({
		Name = "Tracers",
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						for _, v in pairs(workspace:GetChildren()) do
							if v:IsA("Model") and IsAlive(v) and v.Name ~= LocalPlayer.Name then
								if AntiBot.Enabled then
									if Players:FindFirstChild(v.Name) then
										UpdatePos(v)
									else
										if Lines[v] then
											Lines[v]:Destroy()
											Lines[v] = nil
										end
									end
								else
									UpdatePos(v)
								end
							else
								if Lines[v] then
									Lines[v]:Destroy()
									Lines[v] = nil
								end
							end
						end
					until not Tracers.Enabled
					for _, v in pairs(Lines) do
						v:Destroy()
					end
					Lines = {}
				end)
			end
		end
	})
end)

local AntiVoid
task.defer(function()
	local Mode, LastPos
	local Part = Instance.new("Part")
	Part.Size = Vector3.new(9e9, 6, 9e9)
	Part.Position = Vector3.new(LocalPlayer.Character.PrimaryPart.Position.X, 3, LocalPlayer.Character.PrimaryPart.Position.Z)
	Part.Transparency = 1
	Part.Parent = workspace
	Part.Anchored = true
	Part.CanCollide = false
	Part.CanQuery = false
	Part.CanTouch = false
	Part.CastShadow = false
	AntiVoid = TabSections.Player:CreateToggle({
		Name = "Anti Void",
		Callback = function(callback)
			if callback then
				Part.Transparency = 0.75
				task.spawn(function()
					repeat
						task.wait()
						if IsAlive(LocalPlayer.Character) then
							task.defer(function()
								if LocalPlayer.Character:FindFirstChildOfClass("Humanoid").FloorMaterial ~= Enum.Material.Air then
									LastPos = LocalPlayer.Character.PrimaryPart.Position
								end
							end)
							if workspace:WaitForChild("Map"):FindFirstChild("PvpArena") then
								Part.Position = Vector3.new(Part.Position.X, -152, Part.Position.Z)
							else
								Part.Position = Vector3.new(Part.Position.X, 18, Part.Position.Z)
							end
							if LocalPlayer.Character.PrimaryPart.Position.Y <= Part.Position.Y then
								if Mode == "Teleport" then
									LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(LastPos + Vector3.new(0, 6, 0))
								elseif Mode == "Bounce" then
									LocalPlayer.Character.PrimaryPart.Velocity = Vector3.new(LocalPlayer.Character.PrimaryPart.Velocity.X, (math.floor(LastPos.Y) * 2.6), LocalPlayer.Character.PrimaryPart.Velocity.Z)
								end
							end
						end
					until not AntiVoid.Enabled
					Part.Transparency = 1
				end)
			end
		end
	})
	local AntiVoidType = AntiVoid:CreateDropdown({
		Name = "AntiVoid_Type",
		List = {"Bounce", "Teleport"},
		Default = "Teleport",
		Callback = function(callback)
			if callback then
				Mode = callback
			end
		end
	})
end)

local Killsults
task.defer(function()
	local IsDead, IsAlive
	local Connection
	local Signal
	local function OnKill(plr)
		local msg = loadfile("Lime/killsults.lua")()
		if type(msg) == "table" and #msg > 0 then
			local line = msg[math.random(1, #msg)]
			return line:gsub("{plr}", plr.Name)
		end
	end
	Killsults = TabSections.Player:CreateToggle({
		Name = "Killsults",
		Callback = function(callback)
			Connection = BridgeDuel.Knit.GetService("CombatService").OnKill._re
			repeat task.wait() until Connection and Connection.OnClientEvent
			if callback then
				Signal = Connection.OnClientEvent:Connect(function(table1, table2)
					if type(table1) == "table" and type(table2) == "table" then
						if table1.Id then
							for _, killer in pairs(Players:GetPlayers()) do
								local Entity1 = BridgeDuel.Entity.FindByName(killer.Name)
								if Entity1 and Entity1.Id == table1.Id then
									IsAlive = killer
								end
							end
						end
						if table2.Id then
							for _, killed in pairs(Players:GetPlayers()) do
								local Entity2 = BridgeDuel.Entity.FindByName(killed.Name)
								if Entity2 and Entity2.Id == table2.Id then
									IsDead = killed
								end
							end
						end
					end
					if IsAlive and IsDead and IsAlive.Name == LocalPlayer.Name and IsDead.Name ~= LocalPlayer.Name then
						local msg = OnKill(IsDead)
						if msg then
							TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
						else
							warn("not found")
						end
					end
				end)
			else
				if Signal then
					Signal:Disconnect()
					Signal = nil
				end
			end
		end
	})
end)

local Reach
task.defer(function()
	local LocalEntity
	local Distance = 18
	Reach = TabSections.Player:CreateToggle({
		Name = "Reach",
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if IsAlive(LocalPlayer.Character) then
							if BridgeDuel.Constant.Melee.REACH_IN_STUDS ~= Distance then
								BridgeDuel.Constant.Melee.REACH_IN_STUDS = Distance / 2
							end
							LocalEntity = BridgeDuel.Entity.LocalEntity
							if LocalEntity and LocalEntity.Reach ~= Distance then
								LocalEntity.Reach = Distance
							end
						end
					until not Reach.Enabled
					BridgeDuel.Constant.Melee.REACH_IN_STUDS = 9
					if LocalEntity and LocalEntity.Reach then
						LocalEntity.Reach = 18
					end
				end)
			end
		end
	})
	local ReachDistance = Reach:CreateSlider({
		Name = "Distancee",
		Min = 0,
		Max = 22,
		Default = 18,
		Callback = function(callback)
			if callback then
				Distance = callback
			end
		end
	})
end)

local Scaffold
local Rotations
local PlaceCFrame
task.defer(function()
	local original
	Rotations = TabSections.Player:CreateToggle({
		Name = "Rotations",
		Callback = function(callback)
			if callback then
				original = hookmetamethod(game, "__newindex", function(self, key, val)
					if self == LocalPlayer.Character.PrimaryPart and key == "CFrame" then
						if not Flight.Enabled then
							if Scaffold.Enabled and PlaceCFrame then
								return original(self, key, PlaceCFrame)
							elseif KillAura.Enabled and EntityCFrame then
								return original(self, key, EntityCFrame)
							end
						end
					end
					return original(self, key, val)
				end)
			else
				if original then
					hookmetamethod(game, "__newindex", original)
					original = nil
				end
			end
		end
	})
end)

local NoClip
task.defer(function()
	NoClip = TabSections.Player:CreateToggle({
		Name = "No Clip",
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if IsAlive(LocalPlayer.Character) then
							for _, torso in pairs(LocalPlayer.Character:GetChildren()) do
								if torso:IsA("MeshPart") and torso.Name:lower():match("torso") and torso.Name == "CollisionBox" then
									if torso.CanCollide then
										torso.CanCollide = false
									end
								end
							end
							if LocalPlayer.Character.PrimaryPart.CanCollide then
								LocalPlayer.Character.PrimaryPart.CanCollide = false
							end
						end
					until not NoClip.Enabled
					for _, torso in pairs(LocalPlayer.Character:GetChildren()) do
						if torso:IsA("MeshPart") and torso.Name:lower():match("torso") and torso.Name == "CollisionBox" then
							if not torso.CanCollide then
								torso.CanCollide = true
							end
						end
					end
					if not LocalPlayer.Character.PrimaryPart.CanCollide then
						LocalPlayer.Character.PrimaryPart.CanCollide = true
					end
				end)
			end
		end
	})
end)

task.defer(function()
	local original
	NoFallDamage = TabSections.Player:CreateToggle({
		Name = "No Fall Damage",
		Callback = function(callback)
			repeat task.wait() until BridgeDuel.Blink.player_state.take_fall_damage.fire
			if callback then
				original = hookfunction(BridgeDuel.Blink.player_state.take_fall_damage.fire, function(args)
					if NoFallDamage.Enabled and type(args) == "number" and args ~= 0 then
						return original(0)
					end
					return original(args)
				end)
			else
				if original then
					hookfunction(BridgeDuel.Blink.player_state.take_fall_damage.fire, original)
					original = nil
				end
			end
		end
	})
end)

local AutoPlay
task.defer(function()
	AutoPlay = TabSections.World:CreateToggle({
		Name = "Auto Play",
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait(2)
						local EndFrame = LocalPlayer.PlayerGui:WaitForChild("Hotbar"):WaitForChild("MainFrame"):FindFirstChild("GameEndFrame")
						local MatchFrame = LocalPlayer.PlayerGui:WaitForChild("Hotbar"):WaitForChild("MainFrame"):FindFirstChild("MatchmakingFrame")
						if EndFrame.Visible and not MatchFrame.Visible then
							if BridgeDuel.ServerData.Submode ~= "Playground" then
								BridgeDuel.Knit.GetController("MatchController"):EnterQueue(BridgeDuel.ServerData.Submode)
							end
						end
					until not AutoPlay.Enabled
				end)
			end
		end
	})
end)

local BedBreaker
task.defer(function()
	local IsBreaking
	local Distance
	BedBreaker = TabSections.World:CreateToggle({
		Name = "Bed Breaker",
		Callback = function(callback)
			if callback then
				IsBreaking = false
				task.spawn(function()
					repeat
						task.wait(1)
						if IsAlive(LocalPlayer.Character) then
							local Pickaxe = CheckTool("pickaxe") or GetTool("pickaxe")
							if Pickaxe and BridgeDuel.Constant.Pickaxe[Pickaxe.Name] then
								local Bed = GetBed(Distance)
								if Bed and not IsBreaking then
									IsBreaking = true
									BridgeDuel.Blink.item_action.start_break_block.fire({
										position = Bed.Position,
										pickaxe_name = Pickaxe.Name,
										timestamp = workspace:GetServerTimeNow()
									})
									task.wait(0.3)
									BridgeDuel.Blink.item_action.stop_break_block.fire(true)
									task.wait(0.5)
									IsBreaking = false
								end
							end
						end
					until not BedBreaker.Enabled
				end)
			end
		end
	})
	local BreakerDistance = BedBreaker:CreateSlider({
		Name = "Distances",
		Min = 0,
		Max = 15,
		Default = 15,
		Callback = function(callback)
			if callback then
				Distance = callback
			end
		end
	})
end)

task.defer(function()
	local Block, BlockType
	local PlacePosition
	local Expand
	Scaffold = TabSections.World:CreateToggle({
		Name = "Scaffold",
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if IsAlive(LocalPlayer.Character) then
							for i = 1, Expand do
								if UserInputService:IsKeyDown("Space") and not UserInputService:GetFocusedTextBox() then
									if LocalPlayer.Character:FindFirstChildOfClass("Humanoid").FloorMaterial ~= Enum.Material.Air then
										LocalPlayer.Character.PrimaryPart.Velocity = Vector3.new(LocalPlayer.Character.PrimaryPart.Velocity.X, 12, LocalPlayer.Character.PrimaryPart.Velocity.Z)
									end
								end
								if UserInputService:IsKeyDown("LeftShift") and not UserInputService:GetFocusedTextBox() then
									PlacePosition = GetPosition(LocalPlayer.Character.PrimaryPart.Position + LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection * (i * 3.5) - Vector3.yAxis * ((LocalPlayer.Character.PrimaryPart.Size.Y / 2) + LocalPlayer.Character:FindFirstChildOfClass("Humanoid").HipHeight + 4.5))
								else
									PlacePosition = GetPosition(LocalPlayer.Character.PrimaryPart.Position + LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection * (i * 3.5) - Vector3.yAxis * ((LocalPlayer.Character.PrimaryPart.Size.Y / 2) + LocalPlayer.Character:FindFirstChildOfClass("Humanoid").HipHeight + 1.5))
								end
								if Library.DeviceType == "Touch" then
									local LocalEntity = BridgeDuel.Entity.LocalEntity
									if LocalEntity and LocalEntity.IsSneaking then
										PlacePosition = GetPosition(LocalPlayer.Character.PrimaryPart.Position + LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection * (i * 3.5) - Vector3.yAxis * ((LocalPlayer.Character.PrimaryPart.Size.Y / 2) + LocalPlayer.Character:FindFirstChildOfClass("Humanoid").HipHeight + 4.5))
									else
										PlacePosition = GetPosition(LocalPlayer.Character.PrimaryPart.Position + LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection * (i * 3.5) - Vector3.yAxis * ((LocalPlayer.Character.PrimaryPart.Size.Y / 2) + LocalPlayer.Character:FindFirstChildOfClass("Humanoid").HipHeight + 1.5))
									end
								end
								if PlacePosition then
									PlaceCFrame = CFrame.lookAt(LocalPlayer.Character.PrimaryPart.Position, Vector3.new(PlacePosition.X, LocalPlayer.Character.PrimaryPart.Position.Y, PlacePosition.Z))
								else
									PlaceCFrame = nil
								end
								if not IsAtPosition(PlacePosition) then
									Block, BlockType = GetBlocks()
									if Block and BlockType then
										BridgeDuel.Knit.GetController("BlockPlacementController"):PlaceBlock(PlacePosition, BlockType)
									end
								end
							end
						end
					until not Scaffold.Enabled
					Block, BlockType = nil
					PlacePosition = nil
					PlaceCFrame = nil
				end)
			end
		end
	})
	local ScaffoldExpand = Scaffold:CreateSlider({
		Name = "Expand",
		Min = 0,
		Max = 6,
		Default = 1,
		Callback = function(callback)
			if callback then
				Expand = callback
			end
		end
	})
end)

local TimeChanger
task.defer(function()
	local OldClockTime = Lighting.ClockTime
	local NewClockTime
	TimeChanger = TabSections.World:CreateToggle({
		Name = "Time Changer",
		Callback = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if Lighting.ClockTime ~= NewClockTime then
							Lighting.ClockTime = NewClockTime
						end
					until not TimeChanger.Enabled
					Lighting.ClockTime = OldClockTime
				end)
			end
		end
	})
	local TimeChangerClockTime = TimeChanger:CreateSlider({
		Name = "Time",
		Min = 0,
		Max = 24,
		Default = 3,
		Callback = function(callback)
			if callback then
				NewClockTime = callback
			end
		end
	})
end)
