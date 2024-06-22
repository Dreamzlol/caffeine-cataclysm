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
