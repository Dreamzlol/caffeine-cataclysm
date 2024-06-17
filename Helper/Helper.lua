local Unlocker, Caffeine, Rotation = ...

-- Units
local Player = Caffeine.UnitManager:Get("player")
local Target = Caffeine.UnitManager:Get("target")

-- Spells
local spells = Rotation.Spells

-- Gets the index of the talent tree with the most points of the most invested talent tree
---@return number talentIndex
function Caffeine.GetSpec()
	local talentIndex = 0
	local talentPoints = 0

	-- Loop through talent trees
	for i = 1, 3 do
		local _, _, pointsSpent = GetTalentTabInfo(i)

		-- Update if current tree has more points
		if pointsSpent > talentPoints then
			talentIndex = i
			talentPoints = pointsSpent
		end
	end

	return talentIndex
end

-- Determine the class of the player
---@return string className
function Caffeine.GetClass()
	local _, className = UnitClass("player")
	return className
end

--- Determines if a unit is a boss
---@return boolean isBoss
function Caffeine.Unit:CustomIsBoss()
	local id = ObjectID(self:GetOMToken())

	-- Lady Deathwhisper
	if id == 36855 then
		return true
	end

	-- Sindragossa
	if id == 36853 then
		return true
	end

	-- Professor Putricide
	if id == 36678 then
		return true
	end

	-- Skybreaker Sorcerer
	if id == 37116 then
		return true
	end

	-- Kor'kron Battle Mage
	if id == 37117 then
		return true
	end

	-- Blazing Skeleton
	if id == 36791 then
		return true
	end

	-- Savalana Ragefire
	if id == 39747 then
		return true
	end

	-- Baltharus the Warborn
	if id == 39751 then
		return true
	end

	-- General Zarithrian
	if id == 39746 then
		return true
	end

	-- Raid Boss
	if self:IsBoss() then
		return true
	end

	-- Dungeon Boss
	if Player:GetInstanceInfo("party", 2) then
		if UnitClassification(self:GetOMToken()) == "elite" and UnitLevel(self:GetOMToken()) == 82 then
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

--- Checks if the unit is of a specified creature type.
---@return boolean isCreatureType
function Caffeine.Unit:IsCreatureType(creatureType)
	local unitCreatureType = UnitCreatureType(self:GetOMToken())
	return unitCreatureType == creatureType
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

function Caffeine.Unit:InVehicle()
	return UnitInVehicle(self:GetOMToken())
end

function Caffeine.Unit:UsingVehicle()
	return UnitUsingVehicle(self:GetOMToken())
end

-- Event Spell IDs
local spellTable = {
	[72762] = true, -- Lich King: Defile
	[72040] = true, -- Blood Council: Conjure Empowered Flame
	[70126] = true, -- Sindragossa: Beacon
}

local Eventmanager = Caffeine.EventManager:New()
Eventmanager:RegisterWoWEvent("COMBAT_LOG_EVENT_UNFILTERED", function()
	local _, subEvent, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()

	if not spellTable[spellID] then
		return
	end

	if subEvent == "SPELL_CAST_START" and spellID == 72762 then
		local currentTargetGUID = UnitGUID("target")
		if currentTargetGUID == Player:GetGUID() then
			print("|cffffffffDreams|cff00B5FFScripts|cffffffff: Defile on you! Using Nitro Boosts")
			SpellStopCasting()
			UseInventoryItem(8)
		end
	elseif subEvent == "SPELL_CAST_SUCCESS" and spellID == 72040 then
		if destGUID == Player:GetGUID() then
			print("|cffffffffDreams|cff00B5FFScripts|cffffffff: Orb on you! Using Nitro Boosts")
			SpellStopCasting()
			UseInventoryItem(8)
		end
	elseif subEvent == "SPELL_AURA_APPLIED" and spellID == 70126 then
		if destGUID == Player:GetGUID() then
			print("|cffffffffDreams|cff00B5FFScripts|cffffffff: Beacon on you! Using Nitro Boosts")
			SpellStopCasting()
			UseInventoryItem(8)
		end
	end
end)

-- Enemies
local drawEnemiesIDs = {
	[38222] = true, -- Vengeful Shade
	[38711] = true, -- Bone Spike
	[36619] = true, -- Bone Spike
	[38712] = true, -- Bone Spike
}

local function GetDrawingEnemies()
	local drawEnemies = {}

	Caffeine.UnitManager:EnumEnemies(function(unit)
		if unit and unit:Exists() and not unit:IsDead() and Player:GetDistance(unit) <= 40 and drawEnemiesIDs[unit:GetID()] then
			table.insert(drawEnemies, unit)
		end
	end)

	return drawEnemies
end

-- Friends
local debuffs = Caffeine.Globals.SpellBook:GetList(71289, 69279, 69240, 71218, 73019, 73020, 70911, 70126)
local function GetDrawingFriends()
	local drawFriends = {}

	Caffeine.UnitManager:EnumFriends(function(unit)
		if not unit then
			return
		end
		if not unit:Exists() then
			return
		end
		if unit:IsDead() then
			return
		end
		if Player:GetDistance(unit) > 40 then
			return
		end

		if unit:GetAuras():FindAnyFrom(debuffs):IsUp() then
			table.insert(drawFriends, unit)
		end
	end)

	return drawFriends
end

-- Draw
local Draw = Caffeine.Draw:New()
Draw:Sync(function(draw)
	local pPos = Player:GetPosition()
	local drawEnemies = GetDrawingEnemies()
	local drawFriends = GetDrawingFriends()

	-- Enemies
	if drawEnemies then
		for i, object in ipairs(drawEnemies) do
			if not object:Exists() then
				return
			end
			if not object:GetPosition() then
				return
			end
			local ePos = object:GetPosition()

			draw:SetColor(255, 0, 0, 100)
			draw:SetWidth(2)
			draw:Line(pPos.x, pPos.y, pPos.z, ePos.x, ePos.y, ePos.z, 40)

			draw:SetColor(255, 255, 255, 100)
			draw:Outline(ePos.x, ePos.y, ePos.z, 5)

			draw:SetColor(255, 0, 0, 100)
			draw:FilledCircle(ePos.x, ePos.y, ePos.z, 5)

			draw:SetColor(255, 255, 255, 200)
			draw:Text(object:GetName(), "GameFontNormal", ePos.x, ePos.y, ePos.z)
		end
	end

	-- Friends
	if drawFriends then
		for i, object in ipairs(drawFriends) do
			if not object:Exists() then
				return
			end
			if not object:GetPosition() then
				return
			end
			local ePos = object:GetPosition()

			draw:SetColor(255, 165, 0, 100)
			draw:SetWidth(2)
			draw:Line(pPos.x, pPos.y, pPos.z, ePos.x, ePos.y, ePos.z, 40)

			draw:SetColor(255, 255, 255, 100)
			draw:Outline(ePos.x, ePos.y, ePos.z, 5)

			draw:SetColor(255, 165, 0, 100)
			draw:FilledCircle(ePos.x, ePos.y, ePos.z, 5)

			draw:SetColor(255, 255, 255, 200)
			draw:Text(object:GetName(), "GameFontNormal", ePos.x, ePos.y, ePos.z)
		end
	end

	return false
end)

Draw:Enable()
