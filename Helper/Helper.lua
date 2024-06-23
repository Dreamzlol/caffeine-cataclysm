local Unlocker, Caffeine, Rotation = ...

-- Units
local Player = Caffeine.UnitManager:Get("player")
local Target = Caffeine.UnitManager:Get("target")

-- Spells
local spells = Rotation.Spells

-- Determine the class of the player
---@return string className
function Caffeine.GetClass()
	local _, className = UnitClass("player")
	return className
end

--- Determines if a unit is a boss
---@return boolean isBoss
function Caffeine.Unit:CustomIsBoss()
	-- Raid Boss
	if self:IsBoss() then
		return true
	end

	-- Dungeon Boss
	if Player:GetInstanceInfo("party", 2) then
		if UnitClassification(self:GetOMToken()) == "elite" and (UnitLevel(self:GetOMToken()) == 87 or self:IsBoss()) then
			return true
		end
	end

	return false
end

--- Estimates the time it will take for a unit to die
---@return number TimeToDie
function Caffeine.Unit:CustomTimeToDie()
	local timeToDie = self:TimeToDie()
	local healthPercent = self:GetHP()

	if timeToDie == 0 and healthPercent > 10 then
		return 200
	else
		return timeToDie
	end
end

--- Gets the instance information and checks if it matches the provided criteria.
---@param instanceType string
---@param difficultyID number
---@param instanceID number
---@return boolean
function Caffeine.Unit:GetInstanceInfo(instanceType, difficultyID, instanceID)
	local _, type, difficulty, _, _, _, _, instance = GetInstanceInfo()

	if instanceID then
		return type == instanceType and difficulty == difficultyID and instance == instanceID
	else
		return type == instanceType and difficulty == difficultyID
	end
end

--- Gets the instance information
---@return string|number
function Caffeine.Unit:GetInstanceInfoByParameter(param)
	local _, type, difficulty, _, _, _, _, instance = GetInstanceInfo()

	if param == "type" then
		return type
	elseif param == "difficultyID" then
		return difficulty
	elseif param == "instanceID" then
		return instance
	else
		error("Invalid parameter. Valid parameters are 'type', 'difficultyID', or 'instanceID'.")
	end
end

-- Notification System
Caffeine.Notifications = {}
Caffeine.Notifications.Queue = {}
Caffeine.Notifications.Frame = nil

--- Initialize the notification frame
function Caffeine.Notifications:Initialize()
	if not self.Frame then
		self.Frame = CreateFrame("Frame", "CaffeineNotificationFrame", UIParent)
		self.Frame:SetPoint("TOP", 0, -20)
		self.Frame:SetSize(600, 200)

		self.Frame.Icon = self.Frame:CreateTexture(nil, "ARTWORK")
		self.Frame.Icon:SetSize(40, 40)
		self.Frame.Icon:SetPoint("CENTER", self.Frame, "CENTER", -80, -90)

		self.Frame.Text = self.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		self.Frame.Text:SetPoint("LEFT", self.Frame.Icon, "RIGHT", 15, 0)
		self.Frame.Text:SetJustifyH("LEFT")
		self.Frame.Text:SetTextColor(1, 1, 1, 1) -- White text
		self.Frame.Text:SetFont("Fonts\\PTSansNarrow-Bold.ttf", 48, "OUTLINE")

		self.Frame:SetAlpha(0)
		self.Frame:Hide()
	end
end

--- Add a notification to the queue
---@param icon string|number The icon texture or spell ID
---@param message string The notification message
function Caffeine.Notifications:AddNotification(icon, message)
	table.insert(self.Queue, { icon = icon, message = message, time = GetTime() })
	self:Update()
end

--- Update the notification display
function Caffeine.Notifications:Update()
	if #self.Queue > 0 and not self.Frame:IsShown() then
		local notification = table.remove(self.Queue, 1)
		self.Frame.Icon:SetTexture(type(notification.icon) == "number" and GetSpellTexture(notification.icon) or
			notification.icon)
		self.Frame.Text:SetText(notification.message)
		self.Frame:Show()

		-- Fade in
		self.Frame:SetAlpha(0)
		self.Frame:SetScript("OnUpdate", function(self, elapsed)
			local currentAlpha = self:GetAlpha()
			if currentAlpha < 1 then
				self:SetAlpha(math.min(currentAlpha + elapsed * 5, 1))
			elseif currentAlpha == 1 then
				self:SetScript("OnUpdate", nil)
				C_Timer.After(3, function()
					-- Fade out
					self:SetScript("OnUpdate", function(self, elapsed)
						local currentAlpha = self:GetAlpha()
						if currentAlpha > 0 then
							self:SetAlpha(math.max(currentAlpha - elapsed * 5, 0))
						else
							self:SetScript("OnUpdate", nil)
							self:Hide()
							Caffeine.Notifications:Update()
						end
					end)
				end)
			end
		end)
	end
end

--- Create a shorthand function for adding notifications
---@param message string The notification message
---@param icon string|number The icon texture or spell ID
function Caffeine.Notification(message, icon)
	Caffeine.Notifications:AddNotification(icon, message)
end

-- Initialize the notification system
Caffeine.Notifications:Initialize()
