local function CleanEvokerCastbar(castBar)
    if castBar.empoweredFix then return end

    local function UpdateSparkPosition(castBar)
        local progressPercent = castBar.value / castBar.maxValue
        local newX = castBar:GetWidth() * progressPercent
        castBar.Spark:SetPoint("CENTER", castBar, "LEFT", newX, 0)
    end

    local function HideChargeTiers(castBar)
        castBar.ChargeTier1:Hide()
        castBar.ChargeTier2:Hide()
        castBar.ChargeTier3:Hide()
        if castBar.ChargeTier4 then
            castBar.ChargeTier4:Hide()
        end
    end

    castBar:HookScript("OnEvent", function(self)
        if self:IsForbidden() then return end
        if self.barType == "uninterruptable" then
            if self.ChargeTier1 then
                if self.isSArena then
                    self:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
                    self:SetStatusBarColor(0.7, 0.7, 0.7, 1)
                else
                    self:SetStatusBarTexture("UI-CastingBar-Uninterruptable")
                end
                HideChargeTiers(self)
            end
        elseif self.barType == "empowered" then
            if self.isSArena then
                self:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
                self:SetStatusBarColor(1, 0.7, 0, 1)
            else
                self:SetStatusBarTexture("ui-castingbar-filling-standard")
            end
            HideChargeTiers(self)
        end
    end)

    local sparkWidth = castBar.isSArena and 2 or 6
    castBar:HookScript("OnUpdate", function(self)
        if self:IsForbidden() then return end
        if self.barType == "uninterruptable" then
            if self.ChargeTier1 then
                self.Spark:SetAtlas("UI-CastingBar-Pip")
                self.Spark:SetSize(sparkWidth,16)
                UpdateSparkPosition(castBar)
            end
        elseif self.barType == "empowered" then
            self.Spark:SetAtlas("UI-CastingBar-Pip")
            self.Spark:SetSize(sparkWidth,16)
            UpdateSparkPosition(castBar)
        end
    end)

    castBar.empoweredFix = true
end

local castBars = {
    TargetFrameSpellBar,
    FocusFrameSpellBar,
}

local function OnNameplateAdded(self, event, unitID)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
    local frame = nameplate and nameplate.UnitFrame
    if frame then
        CleanEvokerCastbar(frame.castBar)
    end
end

local function OnVariablesLoaded()
    if sArena then
        for i = 1, 3 do
            local arenaFrame = sArena["arena" .. i]
            if arenaFrame and arenaFrame.CastBar then
                arenaFrame.CastBar.isSArena = true
                table.insert(castBars, arenaFrame.CastBar)
            end
        end
    end

    for _, castBar in ipairs(castBars) do
        CleanEvokerCastbar(castBar)
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        OnNameplateAdded(self, event, ...)
    elseif event == "VARIABLES_LOADED" then
        OnVariablesLoaded()
        eventFrame:UnregisterEvent("VARIABLES_LOADED")
    end
end)
eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
eventFrame:RegisterEvent("VARIABLES_LOADED")