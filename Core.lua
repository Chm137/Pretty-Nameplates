local addonName, ns = ...

local Core = CreateFrame("Frame")
Core:RegisterEvent("PLAYER_LOGIN")
Core:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
Core:RegisterEvent("PLAYER_TARGET_CHANGED")
Core:RegisterEvent("GROUP_ROSTER_UPDATE")
Core:RegisterEvent("PLAYER_ENTERING_WORLD")

ns.Core = Core
ns.plates = {}

function ns:FormatNumber(v)
    if not v then return "" end
    if v >= 1000000 then return string.format("%.2fM", v/1000000)
    elseif v >= 1000 then return math.floor(v/1000) .. "K"
    else return math.floor(v) end
end

local function ScanRoster()
    local function CheckUnit(unit)
        if UnitExists(unit) then
            local name = UnitName(unit)
            local _, class = UnitClass(unit)
            if name and class then ns.ClassCache[name] = class end
        end
    end
    CheckUnit("player")
    for i=1, 4 do CheckUnit("party"..i) end
    for i=1, 40 do CheckUnit("raid"..i) end
end

function ns:ApplyCVars()
    -- CVars не трогаем, чтобы не конфликтовать с Sirus
end

Core:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        ns:LoadVariables()
        ns:ApplyCVars()
        ScanRoster()
        print("|cff00ccffPretty Nameplates|r: Loaded. /pnp")
    elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        ScanRoster()
    elseif event == "UPDATE_MOUSEOVER_UNIT" or event == "PLAYER_TARGET_CHANGED" then
        if UnitIsPlayer("mouseover") then
            local n = UnitName("mouseover")
            local _, c = UnitClass("mouseover")
            if n and c then ns.ClassCache[n] = c end
        end
        if UnitIsPlayer("target") then
            local n = UnitName("target")
            local _, c = UnitClass("target")
            if n and c then ns.ClassCache[n] = c end
        end
    end
end)

local function IsNameplate(frame)
    if frame:GetName() then return false end
    local hpBar, castBar = frame:GetChildren()
    return hpBar and castBar and hpBar:GetObjectType() == "StatusBar" and castBar:GetObjectType() == "StatusBar"
end

local function HookNameplate(frame)
    if frame.pnp_processed then return end
    frame.pnp_processed = true
    if ns.CreatePlateFrame then ns:CreatePlateFrame(frame) end
    ns.plates[frame] = true
end

function ns:UpdateAllPlates()
    for frame, _ in pairs(ns.plates) do
        if frame.myPlate and ns.UpdatePlateStyle then
            ns:UpdatePlateStyle(frame.myPlate)
        end
    end
    if ns.UpdateTestFrame then ns:UpdateTestFrame() end
    ns:ApplyCVars()
end

local lastUpdate = 0
Core:SetScript("OnUpdate", function(self, elapsed)
    lastUpdate = lastUpdate + elapsed
    if lastUpdate > 0.1 then
        local frames = {WorldFrame:GetChildren()}
        for _, frame in ipairs(frames) do
            if not frame.pnp_processed and IsNameplate(frame) then
                HookNameplate(frame)
            end
        end
        lastUpdate = 0
    end
end)

SLASH_PRETTYNAMEPLATES1 = "/pnp"
SlashCmdList["PRETTYNAMEPLATES"] = function(msg)
    if ns.ToggleGUI then ns:ToggleGUI() end
end