--[[
    Cheat-Engine (bad exec) helper

    Reports say rewrite is undetected
    by @._stav // sstvskids
]]

local cloneref = cloneref or function(obj)
	return obj
end
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local httpService = cloneref(game:GetService('HttpService'))
local tweenService = cloneref(game:GetService('TweenService'))
local playersService = cloneref(game:GetService('Players'))
local lplr = playersService.LocalPlayer

local sounds = {'rbxassetid://111007032707310', 'rbxassetid://81851569676153', 'rbxassetid://108304966836429'}
local animations = {
	Sword = 'rbxassetid://81023102192808',
	Hammer = 'rbxassetid://113992130601874',
	Blocks = 'rbxassetid://76360831574790',
	Pickaxe = 'rbxassetid://81023102192808',
	GoldApple = 'rbxassetid://80789347313662',
	Potion = 'rbxassetid://80789347313662',
}
local DAMAGE = {
	WoodenSword = 15,
	Sword = 15,
	GoldSword = 35,
	DiamondSword = 45,
	Hammer = 25,
}

local bd = {
	Blink = loadstring(game:HttpGet('https://raw.githubusercontent.com/not-hm/MonsoonForRoblox/refs/heads/main/blink.lua'))(),
	BreakTimes = {
		Bed = 0.3,
		Clay = 1.8,
		WoodPlanks = 3,
		Stone = 5,
		Bricks = 8,
		Iron = 13,
		Diamond = 25,
		TNT = 999,
	},
	BlockPlacementController = {
		PlaceBlock = function(self, blockPos, blockType)
		end
	},
	CombatService = {
		KnockBackApplied = replicatedStorage.Modules.Knit.Services.CombatService.RE:FindFirstChild('KnockBackApplied'),
	},
	CombatConstants = {
		REACH_IN_STUDS = replicatedStorage.Constants.Melee.Reach,
	},
	Entity = {
		FindByPlayer = function(plr)
			for _, v in replicatedStorage.Modules.Knit.Services.EntityService.RF.GetEntities:InvokeServer() do
				if v.Player == plr then
					return v
				end
			end

			return nil
		end,
		FindByCharacter = function(char)
			for _, v in replicatedStorage.Modules.Knit.Services.EntityService.RF.GetEntities:InvokeServer() do
				if v.Character == char then
					return v
				end
			end

			return nil
		end,
	},
	EffectsController = {
		PlaySound = function(self, pos)
			local Part = Instance.new('Part')
			Part.Size = Vector3.new(0.5, 0.5, 0.5)
			Part.CanCollide = false
			Part.CanTouch = false
			Part.CanQuery = false
			Part.Transparency = 1
			Part.Position = pos
			Part.Parent = workspace

			local Sound = Instance.new('Sound')
			Sound.SoundId = sounds[math.random(1, #sounds)]
			Sound.Parent = Part

			Sound:Play()
			Sound.Ended:Connect(function()
				Part:Destroy()
			end)
		end,
	},
	MatchController = {
		EnterQueue = function(self, mode)
			return replicatedStorage.Modules.Knit.Services.MatchService.RF.EnterQueue:InvokeServer(mode)
		end,
	},
	NotificationController = {
		SendNotification = function(self, text, duration)
			local notif = lplr.PlayerGui:WaitForChild("Notifications"):WaitForChild("Notifications").Template:Clone()
			notif.Text = text
			notif.Name = 'TextLabel'
			notif.Visible = true
			notif.Parent = lplr.PlayerGui:WaitForChild("Notifications"):WaitForChild("Notifications")

			task.wait(duration or 3)
			local res = tweenService:Create(notif, TweenInfo.new(1), {
				BackgroundTransparency = 1,
				TextTransparency = 1
			})
			tweenService:Create(notif.UIStroke, TweenInfo.new(1), {
				Transparency = 1
			}):Play()

			res:Play()
			res.Completed:Wait()
			res:Destroy()

			notif:Destroy()
		end
	},
	ServerData = {
		Submode = httpService:JSONDecode(replicatedStorage.Modules.ServerData.Cache.Value),
	},
	ToolService = {
		ToggleBlockSword = function(self, tog, tool)
			return replicatedStorage.Modules.Knit.Services.ToolService.RF.ToggleBlockSword:InvokeServer(tog, tool)
		end,
		AttackPlayerWithSword = function(self, character, crit, tool)
			return replicatedStorage.Modules.Knit.Services.ToolService.RF.AttackPlayerWithSword:InvokeServer(character, crit, tool)
		end,
		PlaceBlock = function(self, blockpos)
			return replicatedStorage.Modules.Knit.Services.ToolService.RF.PlaceBlock:InvokeServer(blockpos)
		end,
	},
	ViewmodelController = {
		GetContainer = function(self)
			return workspace.CurrentCamera
		end,
		PlayAnimation = function(self, tool)
			local toolnme
			if not self:GetContainer():FindFirstChild('Viewmodel') then
				return
			end

			local animObj = self:GetContainer().Viewmodel:WaitForChild(tool, 10)
			if not animObj then
				return
			end

			local anim = animObj.Animation

			if tool:find('Sword') then
				toolnme = 'Sword'
			elseif tool:find('Pickaxe') then
				toolnme = 'Pickaxe'
			elseif tool:find('Potion') then
				toolnme = 'Potion'
			else
				toolnme = tool
			end
			anim.AnimationId = animations[toolnme]

			local track = animObj.AnimationController.Animator:LoadAnimation(anim)
			track.Name = 'ToolAnimation'

			for _, v in animObj.AnimationController.Animator:GetPlayingAnimationTracks() do
				if v.Name == 'ToolAnimation' and (tool:find('Sword') or tool:find('Pickaxe')) then
					v.TimePosition = 0
					v:Stop()
					v:Destroy()
				end
			end

			track:Play()

			return track
		end,
		ToggleLoopedAnimation = function(self, tool, tog)
			if self:GetContainer():FindFirstChild('Viewmodel') then
				if self:GetContainer().Viewmodel:FindFirstChild(tool) then
					local mainpart = self:GetContainer().Viewmodel[tool].Handle.MainPart
					local motor6D = self:GetContainer().Viewmodel[tool].Handle.Motor6D

					if DAMAGE[tool] then
						self.SwordBlocked = tog
						if tog then
							mainpart.C1 = CFrame.new(-1.2, -0.5, 0) * CFrame.fromOrientation(-0.7853981633974483, 2.2689280275926285, -1.0471975511965976)
							if tool ~= 'Hammer' then
								self:GetContainer().Viewmodel[tool].MainPart.Mesh.Scale = Vector3.new(2.8, 5, 0.3)
							end
						else
							mainpart.C1 = CFrame.new(0, 0.5, 0) * CFrame.fromOrientation(0, -3.141592653589793, 0)
							if tool ~= 'Hammer' then
								self:GetContainer().Viewmodel[tool].MainPart.Mesh.Scale = Vector3.new(2, 5, 0.3)
							end
						end
					elseif tool == 'DefaultBow' then
						if tog then
							motor6D.C0 = CFrame.new(2.7, -1.6, -4) * CFrame.fromOrientation(0.20943951023931956, -0.08726646259971647,-0.03490658503988659)
						else
							motor6D.C0 = CFrame.new(3.5, -2.9, -3.8) * CFrame.fromOrientation(0.29670597283903605, 0, 0)
						end
					end
				end
			else
				return
			end
		end,
	},
}

bd.Entity.LocalEntity = bd.Entity.FindByPlayer(lplr)
return bd
