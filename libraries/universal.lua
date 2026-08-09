local Utility = {}
Utility.Services = {
    ReplicatedStorage = game:GetService('ReplicatedStorage'),
    UserInputService = game:GetService('UserInputService'),
    AssetService = game:GetService('AssetService'),
    TweenService = game:GetService('TweenService'),
    HttpService = game:GetService('HttpService'),
    StarterGui = game:GetService('StarterGui'),
    RunService = game:GetService('RunService'),
    Lighting = game:GetService('Lighting'),
    Players = game:GetService('Players'),
}

local RaycastParams = RaycastParams.new()
RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
local Events = {RenderStepped = {}, Heartbeat = {}, Stepped = {}}

local CurrentCamera = workspace.CurrentCamera
local LocalPlayer = Utility.Services.Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

Utility.Misc = {
    GetId = function(id)
        local success, result = pcall(Utility.Services.AssetService.GetGamePlacesAsync, Utility.Services.AssetService) 
        if success and result then
            while true do
                for _, place in result:GetCurrentPage() do
                    if place.PlaceId == id then
                        return true, place.PlaceId
                    end
                end        
                if result.IsFinished then
                    break 
                end            
                result:AdvanceToNextPageAsync()
            end
        else
            warn('util.misc.getid: ' .. tostring(result))
        end
        return false, nil
    end,
    GetDevice = function()
        if Utility.Services.UserInputService and not Utility.Services.UserInputService.MouseEnabled then
            return 'Mobile'
        elseif Utility.Services.UserInputService.KeyboardEnabled or Utility.Services.UserInputService.MouseEnabled then
            return 'Computer'
        end
        return 'Computer'
    end,
    Events = {
        Add = function(eventname, name, intervals, callback)
            if Events[eventname][name] then return end
            local Bind = {
                interval = intervals or 0,
                elapsed = 0,
                callback = callback
            }

            local Handler
            if Bind.interval > 0 then
                Handler = function(DeltaTime)
                    Bind.elapsed += DeltaTime
                    if Bind.elapsed < Bind.interval then
                        return
                    end
                    Bind.elapsed = 0
                    Bind.callback(DeltaTime)
                end
            else
                Handler = Bind.callback
            end
            Bind.connection = Utility.Services.RunService[eventname]:Connect(Handler)
            Events[eventname][name] = Bind
            return Bind
        end,
        Remove = function(eventname, name)
            local Bind = Events[eventname][name]
	        if not Bind then return end

    	    Bind.connection:Disconnect()
	        Events[eventname][name] = nil
        end,
        Update = function(eventname, name, intervals)
            local Bind = Events[eventname][name]
	        if not Bind then return end

            if Bind.interval == intervals then return end
            Bind.connection:Disconnect()
            Bind.interval = intervals or 0
            Bind.elapsed = 0

            local Handler
	        if Bind.interval > 0 then
        		Handler = function(DeltaTime)
    			    Bind.elapsed += DeltaTime
		    	    if Bind.elapsed < Bind.interval then return end
    		    	Bind.elapsed = 0
	    		    Bind.callback()
        		end
	        else
		        Handler = Bind.callback
	        end
	        Bind.connection = Utility.Services.RunService[eventname]:Connect(Handler)
        end
    }
}

Utility.Entity = {
    IsAlive = function(obj)
        if not obj then return end
        if obj:IsA('Player') then
            return obj.Character and obj.Character.PrimaryPart and obj.Character:FindFirstChildOfClass('Humanoid') and obj.Character:FindFirstChildOfClass('Humanoid').Health > 0
        else
            return obj and obj.PrimaryPart and obj:FindFirstChildOfClass('Humanoid') and obj:FindFirstChildOfClass('Humanoid').Health > 0
        end
    end,
    GetPerspective = function()
        if not Utility.Entity.IsAlive(LocalPlayer) then return end
        local Distance = (LocalPlayer.Character:FindFirstChild('Head').Position - CurrentCamera.CFrame.Position).Magnitude
        return Distance < 1 and 'First' or 'Third'
    end,
    GetTeam = function(obj)
        if not obj then return end
        local Entity
        if obj:IsA('Player') then
            Entity = obj
        else
            Entity = obj.Character
        end
        if Entity then
            if Entity.Team and LocalPlayer.Team then
                if Entity.Team == LocalPlayer.Team then
        			return LocalPlayer.Team
	    	    end
		        if Entity.Team.Name == LocalPlayer.Team.Name then
        			return LocalPlayer.Team
	        	end
    	    	if Entity.Team.TeamColor == LocalPlayer.Team.TeamColor then
	    		    return LocalPlayer.Team
        		end
	        	if Entity:GetAttribute('Team') == LocalPlayer:GetAttribute('Team') then
		    	    return LocalPlayer.Team
		        end 
            end
	    end
	    return nil
    end,
    GetPrediction = function(obj, origin, speed, ping)
        local Relative = obj.Position - origin
        local Velocity = obj.AssemblyLinearVelocity
        
        local a = Velocity:Dot(Velocity) - speed * speed
        local b = 2 * Relative:Dot(Velocity)
        local c = Relative:Dot(Relative)
        local disc = b * b - 4 * a * c
        if disc < 0 then
            return obj.Position
        end
        
        local sqrtdisc = math.sqrt(disc)
        local t1 = (-b + sqrtdisc) / (2 * a)
        local t2 = (-b - sqrtdisc) / (2 * a)

        local t
        if t1 > 0 and t2 > 0 then
            t = math.min(t1, t2)
        else
            t = math.max(t1, t2)
        end
        if t <= 0 then
            return obj.Position
        end

        t += ping or 0
        return obj.Position + Velocity * t
    end,
    HasLineOfSight = function(obj)
        if not Utility.Entity.IsAlive(LocalPlayer) or not Utility.Entity.IsAlive(obj) then return false end
        RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        local Result = workspace:Raycast(LocalPlayer.Character.PrimaryPart.Position, obj.Character.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position, RaycastParams)
        return not Result or Result.Instance:IsDescendantOf(obj.Character)
    end,
    Inventory = {
        Backpack = {
            Find = function(toolname)
    			for _, v in LocalPlayer.Backpack:GetChildren() do
	    			if v:IsA('Tool') and v.Name:lower():find(toolname:lower(), 1, true) then
		    			return v
				    end
    			end
	    	end,
    		Get = function()
	    		for _, v in LocalPlayer.Backpack:GetChildren() do
		    		if v:IsA('Tool') then 
                        return v 
                    end
    			end
	    	end,
	    },  
	    Character = {
    		Find = function(toolname)
	    		for _, v in LocalPlayer.Character:GetChildren() do
		    		if v:IsA('Tool') and v.Name:lower():find(toolname:lower(), 1, true) then
			    		return v
				    end
    			end
	    	end,
		    Get = function()
    			for _, v in LocalPlayer.Character:GetChildren() do
	    			if v:IsA('Tool') then 
                        return v 
                    end
		    	end
            end
        }
    },
    Get = {
        Distance = function(MaxDist, Mode, TeamCheck, WallCheck, Direction)
            local Entity, MinDist = nil, math.huge
	    	for _, v in Utility.Services.Players:GetPlayers() do
    			if v ~= LocalPlayer and Utility.Entity.IsAlive(v) then
				    if TeamCheck and Utility.Entity.GetTeam(v) then continue end
                    if WallCheck and not Utility.Entity.HasLineOfSight(v) then continue end

			    	local Distance = (v.Character.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position)
	    			if Distance.Magnitude <= MaxDist then
    					local Angle = math.deg(LocalPlayer.Character.PrimaryPart.CFrame.LookVector:Angle(Distance.Unit))
					    if Direction and Direction < 360 then
				    		if Angle > (Direction / 2) then continue end
			    		end
		    			local Selected
	    				if Mode == 'Closest' then
    						Selected = Distance.Magnitude
					    elseif Mode == 'Lowest' then
				    		Selected = v.Character:FindFirstChildOfClass('Humanoid').Health
			    		elseif Mode == 'Angle' then
		    				Selected = Angle
	    				end
    					if Selected and Selected < MinDist then
				    		MinDist = Selected
			    			Entity = v
		    			end
    				end
	    		end
		    end
		    return Entity
        end,
        Mouse = function(MaxDist, FOV, TeamCheck, WallCheck)
		    local Entity, MinDist = nil, math.huge
		    for _, v in Utility.Services.Players:GetPlayers() do
    			if v ~= LocalPlayer and Utility.Entity.IsAlive(v) then
	    			if TeamCheck and Utility.Entity.GetTeam(v) then continue end
		    		if WallCheck and not Utility.Entity.HasLineOfSight(v) then continue end

			    	local Distance = (v.Character.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position)
		    		if Distance.Magnitude <= MaxDist then
	    				local Pos, Visible = CurrentCamera:WorldToViewportPoint(v.Character.PrimaryPart.Position)
			    		if Visible then
				    		local Dist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
					    	if Dist <= FOV and Dist < MinDist then
							    MinDist = Dist
						    	Entity = v
    						end
	    				end
		    		end
    			end
	    	end
		    return Entity
        end,
        Body = function(obj)
            local R6 = {'Head', 'Torso', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg'}
            local R15 = {'Head', 'UpperTorso', 'LowerTorso', 'LeftUpperArm', 'LeftLowerArm', 'LeftHand', 'RightUpperArm', 'RightLowerArm', 'RightHand', 'LeftUpperLeg', 'LeftLowerLeg', 'LeftFoot', 'RightUpperLeg', 'RightLowerLeg', 'RightFoot'}
            if not obj or not obj:IsA('Model') then return nil end
            local Humanoid = obj:WaitForChild('Humanoid', 67)
            local BodyRig  Humanoid.RigType
            local Parts = {}
            if BodyRig == Enum.HumanoidRigType.R6 then
                for _, v in ipairs(R6) do
                    local part = obj:FindFirstChild(v)
                    if part and part:IsA('BasePart') then
                        table.insert(Parts, part)
                    end
                end
            elseif BodyRig.HumanoidRigType.R15 then
                for _, v in ipairs(R15) do
                    local part = obj:FindFirstChild(v)
                    if part and part:IsA('BasePart') then
                        table.insert(Parts, part)
                    end 
                end
            else
                return nil
            end
            if #Parts == 0 then return nil end
            local BodyPart = nil
            local MinDist = math.huge
            for _, part in ipairs(Parts) do
                local Vector, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                if OnScreen then
                    local Distance = (Vector2.new(Vector.X, Vector.Y) - (Vector2.new(Mouse.X, Mouse.Y)))
                    if Distance.Magnitude < MinDist then
                        MinDist = Distance
                        BodyPart = part
                    end
                end
            end
            return BodyPart
        end
    }
}

Utility.Visual = {
    Highlight = {
        Add = function(obj)
            if not obj or not obj:IsA('Model') then return end
            if obj:FindFirstChildWhichIsA('Highlight') then return end

            local Highlight = Instance.new('Highlight')
            Highlight.FillTransparency = 1
            Highlight.OutlineTransparency = 0
            
            local DefaultColor = Color3.fromRGB(255, 255, 255)
            local NewColor = DefaultColor
            local Entity = Utility.Services.Players:GetPlayerFromCharacter(obj)
            if Entity and Entity.Team and not Entity.Neutral then
                NewColor = Entity.Team.TeamColor.Color
            end
            Highlight.OutlineColor = NewColor
            Highlight.Parent = obj
        end,
        Remove = function(obj)
            if not obj or not obj:IsA('Model') then return end
            local Highlight = obj:FindFirstChildWhichIsA('Highlight')
            if Highlight then Highlight:Destroy() end
        end
    },
    BillBoard = {
        Create = function(obj)
            if not obj or not (obj:IsA('Model') or obj:IsA('BasePart')) then return end
            if obj:FindFirstChildWhichIsA('BillboardGui') then return end

            local BillboardGui = Instance.new('BillboardGui')
            BillboardGui.Parent = obj
            BillboardGui.Adornee = obj
            BillboardGui.AlwaysOnTop = true
            BillboardGui.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
            BillboardGui.Size = UDim2.fromOffset(36, 36)
            BillboardGui.ClipsDescendants = false

            local Frame = Instance.new('Frame')
            Frame.Size = UDim2.fromScale(1, 1)
            Frame.BackgroundTransparency = 1
            Frame.Parent = BillboardGui

            local Corner = Instance.new('UICorner')
            Corner.CornerRadius = UDim.new(0, 4)
            Corner.Parent = Frame

            local Layout = Instance.new('UIListLayout')
            Layout.FillDirection = Enum.FillDirection.Horizontal
            Layout.Padding = UDim.new(0, 4)
            Layout.VerticalAlignment = Enum.VerticalAlignment.Center
            Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            Layout.Parent = Frame
            Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                BillboardGui.Size = UDim2.fromOffset(math.max(Layout.AbsoluteContentSize.X + 8, 36), 36)
            end)
        end,
        Add = {
            Image = function(obj, image, size)
                if not obj or not (obj:IsA('Model') or obj:IsA('BasePart')) then return end
                local BillboardGui = obj:FindFirstChildWhichIsA('BillboardGui')
                if not BillboardGui then return end

                local Container = BillboardGui:FindFirstChildWhichIsA('Frame')
                if not Container then return end

                local ImageLabel = Instance.new('ImageLabel')
                ImageLabel.Size = size or UDim2.fromOffset(32, 32)
                ImageLabel.BackgroundTransparency = 1
                ImageLabel.Image = image
                ImageLabel.Parent = Container

                return ImageLabel
            end,
            Text = function(obj, text, size)
                if not obj or not (obj:IsA('Model') or obj:IsA('BasePart')) then return end
                local BillboardGui = obj:FindFirstChildWhichIsA('BillboardGui')
                if not BillboardGui then return end

                local Container = BillboardGui:FindFirstChildWhichIsA('Frame')
                if not Container then return end

                local TextLabel = Instance.new('TextLabel')
                TextLabel.Size = size or UDim2.fromOffset(48, 32)
                TextLabel.BackgroundTransparency = 1
                TextLabel.Text = tostring(text)
                TextLabel.TextScaled = true
                TextLabel.Font = Enum.Font.GothamBold
                TextLabel.TextColor3 = Color3.new(1, 1, 1)
                TextLabel.TextStrokeTransparency = 0
                TextLabel.Parent = Container
                return TextLabel
            end
        },
        Remove = {
            Image = function(obj, image)
                if not obj or not (obj:IsA('Model') or obj:IsA('BasePart')) then return end
                local BillboardGui = obj:FindFirstChildWhichIsA('BillboardGui')
                if not BillboardGui then return end

                local Container = BillboardGui:FindFirstChildWhichIsA('Frame')
                if not Container then return end

                for _, v in Container:GetChildren() do
                    if v:IsA('ImageLabel') and v.Image == image then
                        v:Destroy()
                    end
                end
            end,
            Text = function(obj, text)
                if not obj or not (obj:IsA('Model') or obj:IsA('BasePart')) then return end
                local BillboardGui = obj:FindFirstChildWhichIsA('BillboardGui')
                if not BillboardGui then return end

                local Container = BillboardGui:FindFirstChildWhichIsA('Frame')
                if not Container then return end

                for _, v in Container:GetChildren() do
                    if v:IsA('TextLabel') and v.Text == tostring(text) then
                        v:Destroy()
                    end
                end
            end,
            Object = function(obj, target)
                if not obj or not (obj:IsA('Model') or obj:IsA('BasePart')) then return end
                local BillboardGui = obj:FindFirstChildWhichIsA('BillboardGui')
                if not BillboardGui then return end

                local Container = BillboardGui:FindFirstChildWhichIsA('Frame')
                if not Container then return end
                for _, v in Container:GetChildren() do
                    if v == target then
                        v:Destroy()
                    end
                end
            end
        },
        Delete = function(obj)
            if not obj or not (obj:IsA('Model') or obj:IsA('BasePart')) then return end
            local BillboardGui = obj:FindFirstChildWhichIsA('BillboardGui')
            if BillboardGui then
                BillboardGui:Destroy()
            end
        end
    }
}

return Utility
