--[[
    Gay bedwars cum dumper
    Reports says ultra-detected
    by @nothm_ // nothm
]]
local cloneref = cloneref or function(obj) return obj end
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local TweenService = cloneref(game:GetService('TweenService'))
local HttpService = cloneref(game:GetService('HttpService'))
local Players = cloneref(game:GetService('Players'))
local LocalPlayer = Players.LocalPlayer

local Collected = {}
local node_modules = ReplicatedStorage:WaitForChild('rbxts_include'):WaitForChild('node_modules')
local easy_games = node_modules:WaitForChild('@easy-games')
local knit_module = easy_games:WaitForChild('knit'):WaitForChild('src'):WaitForChild('Knit'):WaitForChild('KnitClient')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local TS = ReplicatedStorage:WaitForChild('TS')
local KnitClient = require(knit_module)

local function Collect(class, obj)
    if type(obj) ~= 'table' then return end
    Collected[class] = Collected[class] or {
        Functions = {}
    }
    for i, v in pairs(obj) do
        if type(v) == 'function' then
            Collected[class].Functions[tostring(i)] = v
        end
    end
    local mt = getmetatable(obj)
    if mt and mt.__index and type(mt.__index) == 'table' then
        for i, v in pairs(mt.__index) do
            if type(v) == 'function' then
                Collected[class].Functions[tostring(i)] = v
            end
        end
    end
end

local function Scan(folder)
    for _, v in ipairs(folder:GetChildren()) do
        if v:IsA('ModuleScript') then
            local ok, res = pcall(require, v)
            if ok then
                Collected[v.Name] = {
                    Result = res,
                    Functions = {}
                }
                if type(res) == 'function' then
                    Collected[v.Name].Result = res
                elseif type(res) == 'table' then
                    for _, x in pairs(res) do
                        if type(x) == 'table' then
                            Collect(v.Name, x)
                        end
                    end
                    Collect(v.Name, res)
                end
                Scan(v)
            end
        elseif v:IsA('Folder') or v:IsA('Configuration') then
            Scan(v)
        end
    end
end

Scan(TS)
Scan(Modules)
Scan(node_modules)
local Bedwars = {}
Bedwars.GetController = function(name, debug) --// PlayerScripts
    if not debug then debug = false end
    local ok, res = pcall(function()
        return KnitClient.GetController(name)
    end)
    if ok and res then
        for i, v in pairs(res) do
            if type(v) == 'function' then
                if debug then
                    print(i, 'function')
                end
            end
        end
        local mt = getmetatable(res)
        if mt and type(mt.__index) == 'table' then
            for i, v in pairs(mt.__index) do
                if type(v) == 'function' then
                    if debug then
                        print(i, 'function')
                    end
                    if res[i] == nil then
                        res[i] = v
                    end
                end
            end
        end
        return res
    else
        warn('[bw_dumper]: unable to find ' .. tostring(name))
        return nil
    end
end
Bedwars.GetModule = function(name) --// ReplicatedStorage
    if Collected[name] then
        if type(Collected[name].Result) == 'function' then
            return Collected[name].Result
        end
        return Collected[name].Functions
    end
    warn('[bw_dumper]: unable to find ' .. tostring(name))
    return nil
end

return Bedwars
