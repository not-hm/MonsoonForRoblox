repeat task.wait() until game:IsLoaded() and workspace.CurrentCamera
local cloneref = cloneref or function(obj) return obj end
local shared = shared or getgenv()
shared.Monsoon = shared.Monsoon or {}

local PlaceId
local Experience = {139566161526375, 71480482338212, 6872265039}
for _, v in pairs(Experience) do
    local Status, Id = Utility.Misc.GetId(v)
    if not Status then continue end
    local success, result = pcall(function()
        PlaceId = Id
    end)
    if not success then
        warn(result)
    end
end

if string.find(({identifyexecutor()})[1], 'Xeno') or not (debug.getupvalue or debug.getconstants or hookfunction) then
	shared.Monsoon.Status = 'bad'
end
if require and (PlaceId == 11630038968 or PlaceId == 10810646982 or PlaceId == 139566161526375) then
	local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
	local suc = pcall(require, ReplicatedStorage.Blink.Client)
	if not suc then
		shared.Monsoon.Status = 'bad'
	end
elseif not require then
	shared.Monsoon.Status = 'bad'
end

shared.Monsoon.Status = shared.Monsoon.Status or 'good'
if PlaceId == 11630038968 or PlaceId == 10810646982 or PlaceId == 139566161526375 then
	shared.Monsoon.Game = 'bridge_duel'
elseif PlaceId == 71480482338212 then
	shared.Monsoon.Game = 'bed_fight'
elseif PlaceId == 6872265039 then
	shared.Monsoon.Game = 'bedwars'
else
	shared.Monsoon.Game = 'universal'
end

repeat task.wait() until shared.Monsoon.Status and shared.Monsoon.Game
loadstring(game:HttpGet('https://raw.githubusercontent.com/not-hm/MonsoonForRoblox/refs/heads/main/games/' .. shared.Monsoon.Game .. '/' .. shared.Monsoon.Status .. '.lua'))()
