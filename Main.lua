--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                         NexusUI                                ║
    ║           Modern Rendering Framework for Roblox                ║
    ║                      Version 1.0.0                             ║
    ╚═══════════════════════════════════════════════════════════════╝
    
    использование:
    local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kingofaim/NexusUI/main/Main.lua"))()
    
    local Window = NexusUI:CreateWindow({
        Title = "My Script",
        Subtitle = "autofarm"
    })
]]

local NexusUI = {
    Version = "1.0.0",
    _modules = {},
    _loaded = false,
    _instances = {},
    _connections = {}
}

local GITHUB_RAW = "https://raw.githubusercontent.com/YOUR_USERNAME/NexusUI/main/"

local MODULES_ORDER = {
    "Core",
    "State",
    "Style",
    "Animation",
    "Input",
    "Renderer",
    "Components"
}

local function Fetch(name)
    local success, result = pcall(function()
        return game:HttpGet(GITHUB_RAW .. name .. ".lua")
    end)
    if not success then
        warn("[NexusUI] Fetch failed:", name)
        return nil
    end
    return result
end

local function LoadModule(name)
    local source = Fetch(name)
    if not source then return nil end
    
    local fn, err = loadstring(source)
    if not fn then
        warn("[NexusUI] Parse failed:", name, err)
        return nil
    end
    
    local success, module = pcall(fn, NexusUI)
    if not success then
        warn("[NexusUI] Execute failed:", name, module)
        return nil
    end
    
    return module
end

local function Init()
    for _, name in ipairs(MODULES_ORDER) do
        local module = LoadModule(name)
        if module then
            NexusUI._modules[name] = module
            NexusUI[name] = module
        end
    end
    
    NexusUI._loaded = true
    
    if NexusUI.State then
        NexusUI.State:Set("ready", true)
        NexusUI.State:Emit("init")
    end
    
    return NexusUI
end

function NexusUI:GetModule(name)
    return self._modules[name]
end

function NexusUI:IsLoaded()
    return self._loaded
end

function NexusUI:Create(className, props)
    if not self.Renderer then return nil end
    return self.Renderer:Create(className, props)
end

function NexusUI:Mount(element, parent)
    if not self.Renderer then return nil end
    return self.Renderer:Mount(element, parent)
end

function NexusUI:Unmount(element)
    if not self.Renderer then return end
    self.Renderer:Unmount(element)
end

function NexusUI:SetTheme(theme)
    if not self.Style then return end
    self.Style:SetTheme(theme)
end

function NexusUI:Destroy()
    if self.State then
        self.State:Emit("destroy")
    end
    
    for _, conn in pairs(self._connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    
    for _, inst in pairs(self._instances) do
        if typeof(inst) == "Instance" then
            inst:Destroy()
        end
    end
    
    self._connections = {}
    self._instances = {}
end

return Init()
