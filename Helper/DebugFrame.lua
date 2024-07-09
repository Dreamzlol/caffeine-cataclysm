local Unlocker, Caffeine, Rotation, SimpleRotations = ...

-- Units
local Player = Caffeine.UnitManager:Get("player")
local Target = Caffeine.UnitManager:Get("target")

-- Create the debug frame
local mainFrame = CreateFrame("Frame", "MainFrame", UIParent)
mainFrame:SetSize(300, 200)
mainFrame:SetPoint("CENTER")
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
mainFrame:Hide()

-- Create a black background texture
local bg = mainFrame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(mainFrame)
bg:SetColorTexture(0, 0, 0, 0.7)

-- Create a border
local border = CreateFrame("Frame", nil, mainFrame)
border:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", -1, 1)
border:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", 1, -1)

-- Create title text
local titleText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 5, -5)
titleText:SetText("|cffFFFFFFDreams|cff00B5FFScripts |cffFFFFFFDebugFrame")

-- Function to toggle the main frame
local function ToggleMainFrame()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end

-- Register a slash command to toggle the main frame
_G["SLASH_TOGGLEMAINFRAME1"] = "/df"
SlashCmdList["TOGGLEMAINFRAME"] = ToggleMainFrame

-- Create table to hold the debugInfo
local debugInfo = {
    -- Player
    { title = "Player", headline = true, },
    { text = "HP/MP: ", value = function() return tostring(Player:GetHP()) .. "/" .. tostring(Player:GetPP()) end },
    { text = "GetGCD: ", value = function() return tostring(Player:GetGCD()) end, },
    { text = "InstanceType: ", value = function() return tostring(Player:GetInstanceInfoByParameter("type")) end },
    { text = "DifficultyID: ", value = function() return tostring(Player:GetInstanceInfoByParameter("difficultyID")) end },
    { text = "InstanceID: ", value = function() return tostring(Player:GetInstanceInfoByParameter("instanceID")) end },
    { text = "GetDistance(Target): ", value = function() return tostring(Player:GetDistance(Target)) end },
    { text = "CanSee(Target): ", value = function() return tostring(Player:CanSee(Target)) end },
    { text = "IsMounted: ", value = function() return tostring(IsMounted()) end },
    { text = "IsFacing(Target): ", value = function() return tostring(Player:IsFacing(Target)) end },
    { text = "IsAffectingCombat: ", value = function() return tostring(Player:IsAffectingCombat()) end },
    { title = "Target", headline = true },
    { text = "Name: ", value = function() return tostring(Target:GetName()) end },
    { text = "HP/MP: ", value = function() return tostring(Target:GetHP()) .. "/" .. tostring(Target:GetPP()) end },
    { text = "GUID: ", value = function() return tostring(Target:GetGUID()) end },
    { text = "ID: ", value = function() return tostring(Caffeine.UnitManager.Target:GetID()) end },
    { text = "Classification: ", value = function() return tostring(UnitClassification(Target:GetOMToken())) end },
    { text = "IsBoss/CustomIsBoss: ", value = function() return tostring(Target:IsBoss()) .. "/" .. tostring(Target:CustomIsBoss()) end },
    { text = "GetDistance(Player): ", value = function() return tostring(Target:GetDistance(Player)) end },
    { text = "CanSee(Player): ", value = function() return tostring(Target:CanSee(Player)) end },
    { text = "IsHostile: ", value = function() return tostring(Target:IsHostile()) end },
    { text = "IsFriendly: ", value = function() return tostring(Target:IsFriendly()) end },
    { text = "IsEnemy: ", value = function() return tostring(Target:IsEnemy()) end },
    { text = "IsFacing(Player): ", value = function() return tostring(Target:IsFacing(Player)) end },
    { text = "IsPCU: ", value = function() return tostring(Target:IsPCU()) end },
    { text = "IsAffectingCombat: ", value = function() return tostring(Target:IsAffectingCombat()) end },
    { text = "GetCastingSpell: ", value = function() return tostring(Target:GetCastingOrChannelingSpell()) end },
    { text = "EnemiesInRange(10): ", value = function() return tostring(Target:GetEnemies(10)) end },
    { text = "IsBehind(Player): ", value = function() return tostring(Target:IsBehind(Player)) end },
    { text = "TimeToDie: ", value = function() return tostring(Target:TimeToDie()) end },
    { text = "IsInterruptible: ", value = function() return tostring(Target:IsInterruptible()) end },
    { text = "HasAnyStealableAura: ", value = function() return tostring(Target:GetAuras():HasAnyStealableAura()) end },
    { text = "IsDead: ", value = function() return tostring(Target:IsDead()) end },
    { text = "Exists: ", value = function() return tostring(Target:Exists()) end },
    { text = "IsMoving: ", value = function() return tostring(Target:IsMoving()) end },
}

-- Function to colorize text based on boolean value
local function ColorizeBool(value)
    if value == "true" then
        return "|cff00ff00" .. value .. "|r" -- Green for 'true'
    elseif value == "false" then
        return "|cffff0000" .. value .. "|r" -- Red for 'false'
    else
        return "|cffffffff" .. value .. "|r" -- White for other values
    end
end

-- Create and populate the table rows
local function CreateAndPopulateRows(parent, data)
    local rowHeight = 20
    local contentHeight = 0
    local maxWidth = 0
    local headerFontHeight = 16
    local normalFontHeight = 12
    local headerColor = {r = 1, g = 1, b = 1} -- Yellow
    local normalColor = {r = 1, g = 0.82, b = 0} -- White
    local trueColor = {r = 0, g = 1, b = 0} -- Green
    local falseColor = {r = 1, g = 0, b = 0} -- Red

    if parent.rows then
        for _, row in ipairs(parent.rows) do
            row:Hide()
            row:SetParent(nil)
        end
    end
    parent.rows = {}

    -- Create a row for each entry in the data table
    for i, info in ipairs(data) do
        local row = CreateFrame("Frame", nil, parent)
        row:SetHeight(rowHeight)
        parent.rows[i] = row

        local cell = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        cell:SetPoint("LEFT", 10, 0)

        if info.headline then
            -- Set the font size and color based on whether this is a header or not
            cell:SetFont(GameFontNormal:GetFont(), headerFontHeight)
            cell:SetTextColor(headerColor.r, headerColor.g, headerColor.b)
            cell:SetText(info.title)
            contentHeight = contentHeight + rowHeight + 10 -- Additional spacing after header
        else
            -- Set the font size and color based on whether this is a boolean or not
            cell:SetFont(GameFontNormal:GetFont(), normalFontHeight)

            local value = info.value and info.value() or "nil"
            local coloredValue = value

            -- Special handling for concatenated boolean values in 'IsBoss/CustomIsBoss'
            if string.find(info.text, "IsBoss/CustomIsBoss") then
                local isBossValue, customIsBossValue = strsplit("/", value)
                coloredValue = ColorizeBool(isBossValue) .. " / " .. ColorizeBool(customIsBossValue)
            else
                coloredValue = ColorizeBool(value)
            end

            cell:SetText(info.text .. coloredValue)
            contentHeight = contentHeight + rowHeight
        end

        -- Adjust the width to the widest row
        maxWidth = math.max(maxWidth, cell:GetStringWidth())

        -- Position the row
        row:SetPoint("TOPLEFT", 10, -10 - contentHeight)
        row:SetPoint("TOPRIGHT", -10, -10 - contentHeight)
    end

    -- Adjust the frame size based on content
    parent:SetHeight(contentHeight + 60)
    parent:SetWidth(maxWidth + 40)
end

-- Create and populate table rows
local function UpdateDebugInformation()
    CreateAndPopulateRows(mainFrame, debugInfo)
end

-- Update the debug table every 0.5 seconds
local updateTimer = 0
mainFrame:SetScript(
    "OnUpdate",
    function(self, elapsed)
        updateTimer = updateTimer + elapsed
        if updateTimer >= 0.5 then
            UpdateDebugInformation()
            updateTimer = 0
        end
    end
)

UpdateDebugInformation()