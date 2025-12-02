local addonName, ns = ...

function ns:CreateCastbar(myPlate)
    local cb = CreateFrame("StatusBar", nil, myPlate)
    cb:SetStatusBarTexture(ns.defaults.texture)
    cb:SetStatusBarColor(1, 0.8, 0)
    cb:Hide()
    
    local bg = cb:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(cb)
    bg:SetTexture(0,0,0, 0.75)
    
    local backdrop = CreateFrame("Frame", nil, cb)
    backdrop:SetPoint("TOPLEFT", -1, 1)
    backdrop:SetPoint("BOTTOMRIGHT", 1, -1)
    backdrop:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
    backdrop:SetBackdropBorderColor(0, 0, 0, 1)
    
    local icon = cb:CreateTexture(nil, "OVERLAY") 
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    
    local iconBg = cb:CreateTexture(nil, "ARTWORK")
    iconBg:SetTexture(0, 0, 0, 1) 
    iconBg:SetPoint("CENTER", icon, "CENTER")
    cb.iconBg = iconBg
    
    local shield = cb:CreateTexture(nil, "OVERLAY")
    shield:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull") 
    shield:SetSize(14, 14)
    shield:SetPoint("CENTER", icon, "CENTER")
    shield:Hide()
    cb.shield = shield
    
    local timeText = cb:CreateFontString(nil, "OVERLAY")
    timeText:SetFont(ns.defaults.font, 8, "OUTLINE")
    timeText:SetPoint("RIGHT", cb, "RIGHT", -4, 0)
    
    local spellText = cb:CreateFontString(nil, "OVERLAY")
    spellText:SetFont(ns.defaults.font, 8, "OUTLINE")
    spellText:SetPoint("LEFT", cb, "LEFT", 4, 0)
    spellText:SetPoint("RIGHT", timeText, "LEFT", -5, 0)
    spellText:SetJustifyH("LEFT")
    spellText:SetWordWrap(false)
    
    myPlate.castbar = cb
    cb.icon = icon
    cb.timeText = timeText
    cb.spellText = spellText
end

function ns:UpdateCastbar(myPlate, parentFrame)
    if not PrettyNameplatesDB.showCastbar then myPlate.castbar:Hide() return end
    local plateName = myPlate.nameText:GetText()
    if not plateName then myPlate.castbar:Hide() return end

    local unit = nil
    if UnitName("target") == plateName and parentFrame:GetAlpha() >= 0.5 then unit = "target"
    elseif UnitName("mouseover") == plateName then unit = "mouseover" end
    
    if not unit then myPlate.castbar:Hide() return end
    
    local spell, rank, displayName, iconPath, startTime, endTime, isTrade, castID, notInterruptible = UnitCastingInfo(unit)
    local channel = false
    if not spell then
        spell, rank, displayName, iconPath, startTime, endTime, isTrade, notInterruptible = UnitChannelInfo(unit)
        channel = true
    end
    
    if spell then
        myPlate.castbar:Show()
        myPlate.castbar:SetMinMaxValues(startTime/1000, endTime/1000)
        local currentTime = GetTime()
        if channel then myPlate.castbar:SetValue(endTime/1000 - (currentTime - startTime/1000))
        else myPlate.castbar:SetValue(currentTime) end

        myPlate.castbar.spellText:SetText(spell)
        myPlate.castbar.icon:SetTexture(iconPath)
        myPlate.castbar.icon:Show()
        
        if notInterruptible then
            myPlate.castbar:SetStatusBarColor(0.6, 0.6, 0.6)
            if myPlate.castbar.shield then myPlate.castbar.shield:Show() end
        else
            local c = PrettyNameplatesDB.castColor or ns.defaults.castColor
            myPlate.castbar:SetStatusBarColor(c.r, c.g, c.b)
            if myPlate.castbar.shield then myPlate.castbar.shield:Hide() end
        end
        
        local timeLeft = (endTime/1000) - currentTime
        if timeLeft < 0 then timeLeft = 0 end
        myPlate.castbar.timeText:SetText(string.format("%.1f", timeLeft))
    else
        myPlate.castbar:Hide()
    end
end