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

            if not name then break end
            
            if ns.ImportantBuffs[spellId] then
                local frame = myPlate.important[impIndex]
                if frame then
                    frame:Show()
                    frame.icon:SetTexture(icon)
                    
    for i=1, #myPlate.auras do myPlate.auras[i]:Hide() end
    for i=1, #myPlate.important do myPlate.important[i]:Hide() end
end