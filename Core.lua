local addonName, ns = ...

local Core = CreateFrame("Frame")
Core:RegisterEvent("PLAYER_LOGIN")
Core:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
Core:RegisterEvent("PLAYER_TARGET_CHANGED")
Core:RegisterEvent("GROUP_ROSTER_UPDATE")
Core:RegisterEvent("PLAYER_ENTERING_WORLD")
Core:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

ns.Core = Core
ns.plates = {}
ns.AuraCache = {}   -- [GUID] = { [SpellID] = { exp, icon, count, type } }
ns.GUIDsByName = {} -- [Name] = { [GUID] = true }
ns.PetNamesCache = {
    ["Ebon Gargoyle"] = true,
    ["Ebongargoyle"] = true,
    ["Gargoyle"] = true,
    ["Горгулья"] = true,
    ["Вороная горгулья"] = true,
    ["Army of the Dead"] = true,
    ["Army"] = true,
    ["Ghoul"] = true,
    ["Вурдалак"] = true,
    ["Войско мертвых"] = true,
    ["Voidwalker"] = true,
    ["Succubus"] = true,
    ["Felhunter"] = true,
    ["Felguard"] = true,
    ["Imp"] = true,
    ["Демон Бездны"] = true,
    ["Суккуб"] = true,
    ["Охотник Скверны"] = true,
    ["Страж Скверны"] = true,
    ["Бес"] = true,
    ["Spirit Wolf"] = true,
    ["Дух волка"] = true,
    ["Treant"] = true,
    ["Древень"] = true,
    ["Water Elemental"] = true,
    ["Элементаль воды"] = true,
    ["Shadowfiend"] = true,
    ["Исчадие Тьмы"] = true,
}

function ns:FormatNumber(v)
    if not v then return "" end
    if v >= 1000000 then
        return string.format("%.2fM", v / 1000000)
    elseif v >= 1000 then
        return math.floor(v / 1000) .. "K"
    else
        return math.floor(v)
    end
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
    for i = 1, 4 do CheckUnit("party" .. i) end
    for i = 1, 40 do CheckUnit("raid" .. i) end
end

function ns:ApplyCVars()
    -- CVars не трогаем, чтобы не конфликтовать с Sirus
end

Core:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        ns:LoadVariables()
        ns:ApplyCVars()
        ScanRoster()
        print("|cff00ccffPretty Nameplates|r: Loaded. /pnp")
    elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        ScanRoster()
        -- Scan for pets in group/arena
        for i = 1, 4 do
            local unit = "party" .. i .. "pet"
            if UnitExists(unit) then ns.PetNamesCache[UnitName(unit)] = true end
        end
        for i = 1, 5 do
            local unit = "arena" .. i .. "pet"
            if UnitExists(unit) then ns.PetNamesCache[UnitName(unit)] = true end
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName, spellSchool, auraType, amount = ...

        -- Pet Detection
        if sourceName and sourceFlags then
            local IS_PET = bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) > 0
            local IS_GUARDIAN = bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0
            if IS_PET or IS_GUARDIAN then
                ns.PetNamesCache[sourceName] = true
            end
        end

        -- Aura Tracking
        if eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH" or eventType == "SPELL_AURA_APPLIED_DOSE" then
            if sourceGUID == UnitGUID("player") and destGUID then
                if not ns.AuraCache[destGUID] then ns.AuraCache[destGUID] = {} end
                -- We need duration/icon. CL doesn't give it. We must rely on SpellInfo.
                local name, _, icon = GetSpellInfo(spellId)
                -- We don't get expirationTime from CL. We must guess based on duration?
                -- Or just store "start time" and "duration" if we knew it.
                -- Since we can't get duration easily without a lookup table, we might just show "present" or try to guess.
                -- BUT, user said "binding timers to GUID".
                -- We can't get exact timer from CL in 3.3.5a without knowing the spell duration.
                -- Let's assume we just show it exists, or maybe we can't show timer accurately.
                -- Wait, UnitAura gives duration. We can cache it from Target/Mouseover?
                -- For now, let's just store "GetTime()" as start.
                ns.AuraCache[destGUID][spellId] = {
                    name = name,
                    icon = icon,
                    startTime = GetTime(),
                    -- We'll need a duration DB or assume standard. For now, let's just show it.
                    -- Actually, let's try to get duration from GetSpellInfo? No, it doesn't return duration.
                    -- We will just show it without timer if we don't know duration, or look up a hardcoded table?
                    -- Let's just store it.
                    count = amount or 1,
                    type = auraType
                }

                if destName then
                    if not ns.GUIDsByName[destName] then ns.GUIDsByName[destName] = {} end
                    ns.GUIDsByName[destName][destGUID] = true
                end
            end
        elseif eventType == "SPELL_AURA_REMOVED" then
            if sourceGUID == UnitGUID("player") and destGUID and ns.AuraCache[destGUID] then
                ns.AuraCache[destGUID][spellId] = nil
            end
        elseif eventType == "UNIT_DIED" then
            if destGUID then
                ns.AuraCache[destGUID] = nil
                if destName and ns.GUIDsByName[destName] then
                    ns.GUIDsByName[destName][destGUID] = nil
                end
            end
        end
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
        local frames = { WorldFrame:GetChildren() }
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
