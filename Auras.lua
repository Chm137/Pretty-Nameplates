local addonName, ns = ...

function ns:CreateAuras(myPlate)
    myPlate.auras = {}
    for i = 1, 8 do
        local frame = CreateFrame("Frame", nil, myPlate)
        frame:SetSize(16, 16)
        
        local icon = frame:CreateTexture(nil, "BACKGROUND")
        icon:SetAllPoints()
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        
        local cd = frame:CreateFontString(nil, "OVERLAY")
        cd:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        cd:SetPoint("CENTER", 0, 0)
        cd:SetTextColor(1, 1, 0)
        
        local border = frame:CreateTexture(nil, "OVERLAY")
        border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
        border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
        border:SetAllPoints()
        
        frame.icon = icon
        frame.cd = cd
        frame.border = border
        frame:Hide()
        myPlate.auras[i] = frame
    end
    
    myPlate.important = {}
    for i = 1, 3 do
        local frame = CreateFrame("Frame", nil, myPlate)
        frame:SetSize(22, 22)
        
        local icon = frame:CreateTexture(nil, "BACKGROUND")
        icon:SetAllPoints()
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        
        local cd = frame:CreateFontString(nil, "OVERLAY")
        cd:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        cd:SetPoint("CENTER", 0, 0)
        cd:SetTextColor(1, 1, 1)
        
        local bd = CreateFrame("Frame", nil, frame)
        bd:SetPoint("TOPLEFT", -1, 1)
        bd:SetPoint("BOTTOMRIGHT", 1, -1)
        bd:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
        bd:SetBackdropBorderColor(1, 0, 0, 1)
        
        frame.icon = icon
        frame.cd = cd
        frame:Hide()
        myPlate.important[i] = frame
    end
end

function ns:UpdateAuras(myPlate, parentFrame)
    -- БЕЗОПАСНАЯ ЗАГРУЗКА НАСТРОЕК
    local db = PrettyNameplatesDB or ns.defaults

    local unit = nil
    local plateName = myPlate.nameText:GetText()
    
    if not plateName then
        ns:HideAllAuras(myPlate)
        return
    end

    if UnitName("target") == plateName and parentFrame:GetAlpha() >= 0.5 then
        unit = "target"
    elseif UnitName("mouseover") == plateName then
        unit = "mouseover"
    end
    
    if not unit then
        ns:HideAllAuras(myPlate)
        return
    end
    
    if db.showAuras then
        local auraIndex = 1
        for i = 1, 40 do
            local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster = UnitDebuff(unit, i)
            if not name then break end
            
            if unitCaster == "player" then
                local frame = myPlate.auras[auraIndex]
                if frame then
                    frame:Show()
                    frame.icon:SetTexture(icon)
                    local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"]
                    frame.border:SetVertexColor(color.r, color.g, color.b)
                    
                    -- ЗУМ
                    if db.zoomIcons then frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    else frame.icon:SetTexCoord(0, 1, 0, 1) end
                    
                    frame:SetScript("OnUpdate", function(self, elapsed)
                        if expirationTime and expirationTime > 0 then
                            local timeLeft = expirationTime - GetTime()
                            if timeLeft <= 0 then self.cd:SetText("")
                            elseif timeLeft > 60 then self.cd:SetText(math.ceil(timeLeft/60).."m")
                            else self.cd:SetText(math.floor(timeLeft)) end
                        else self.cd:SetText("") end
                    end)
                    auraIndex = auraIndex + 1
                end
            end
            if auraIndex > 8 then break end
        end
        for i = auraIndex, #myPlate.auras do myPlate.auras[i]:Hide() end
    else
        for i=1, #myPlate.auras do myPlate.auras[i]:Hide() end
    end
    
    local impIndex = 1
    if ns.ImportantBuffs and db.showImportant then
        for i = 1, 40 do
            local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitBuff(unit, i)
            if not name then break end
            
            if ns.ImportantBuffs[spellId] then
                local frame = myPlate.important[impIndex]
                if frame then
                    frame:Show()
                    frame.icon:SetTexture(icon)
                    
                    if db.zoomIcons then frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    else frame.icon:SetTexCoord(0, 1, 0, 1) end
                    
                    frame:SetScript("OnUpdate", function(self, elapsed)
                        if expirationTime and expirationTime > 0 then
                            local timeLeft = expirationTime - GetTime()
                            if timeLeft <= 0 then self.cd:SetText("")
                            else self.cd:SetText(math.floor(timeLeft)) end
                        else self.cd:SetText("") end
                    end)
                    
                    impIndex = impIndex + 1
                end
            end
            if impIndex > 3 then break end
        end
    end
    for i = impIndex, #myPlate.important do myPlate.important[i]:Hide() end
end

function ns:HideAllAuras(myPlate)
    for i=1, #myPlate.auras do myPlate.auras[i]:Hide() end
    for i=1, #myPlate.important do myPlate.important[i]:Hide() end
end