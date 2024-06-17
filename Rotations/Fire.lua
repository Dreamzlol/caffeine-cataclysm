local Unlocker, Caffeine, Rotation = ...

-- Loader
if Caffeine.GetClass() ~= "MAGE" then
	return
end

-- Module
local Module = Caffeine.Module:New("fire")

-- Units
local Player = Caffeine.UnitManager:Get("player")
local Target = Caffeine.UnitManager:Get("target")
local None = Caffeine.UnitManager:Get("none")

-- Spells
local spells = Rotation.Spells

-- items
local items = Rotation.Items

-- APLs
local PreCombatAPL = Caffeine.APL:New("precombat")
local DefaultAPL = Caffeine.APL:New("default")

-- NPC Blacklist
local blacklistUnitById = {
	[37695] = true, -- Drudge Ghoul: 37695
	[37698] = true, -- Shambling Horror: 37698
	[28926] = true, -- Spark of lonar: 28926
	[28584] = true, -- Unbound Firestorm: 28584
	[27737] = true, -- Risen Zombie: 27737
	[27651] = true, -- Phtasmal Fire: 27651
	[37232] = true, -- Nerub'ar Broodling
	[37799] = true, -- Vile Spirit: 37799
	[38104] = true, -- Plagued Zombie: 38104
	[37907] = true, -- Rot Worm: 37907
	[36633] = true, -- Ice Sphere: 36734
	[39190] = true, -- Wicked Spirit: 39190
}

local HighestHPEnemie = Caffeine.UnitManager:CreateCustomUnit("highest", function(unit)
	local highest = nil
	local highestHP = 0

	Caffeine.UnitManager:EnumEnemies(function(unit)
		if unit:IsDead() then
			return false
		end

		if Player:GetDistance(unit) > 41 then
			return false
		end

		if not Player:CanSee(unit) then
			return false
		end

		if not unit:IsAffectingCombat() then
			return false
		end

		if not unit:IsEnemy() then
			return false
		end

		if not unit:IsHostile() then
			return false
		end

		if blacklistUnitById[unit:GetID()] then
			return false
		end

		local hp = unit:GetHP()
		if hp > highestHP then -- Change this line to check for higher HP
			highest = unit
			highestHP = hp
		end
	end)

	if not highest then
		highest = None
	end

	return highest
end)

local LivingBomb = Caffeine.UnitManager:CreateCustomUnit("livingBomb", function(unit)
	local livingBomb = nil

	Caffeine.UnitManager:EnumEnemies(function(unit)
		if unit:IsDead() then
			return false
		end

		if Player:GetDistance(unit) > 41 then
			return false
		end

		if not Player:CanSee(unit) then
			return false
		end

		if not unit:IsAffectingCombat() then
			return false
		end

		if not unit:IsHostile() then
			return false
		end

		if not unit:IsEnemy() then
			return false
		end

		if unit:CustomTimeToDie() < 12 then
			return false
		end

		if blacklistUnitById[unit:GetID()] then
			return false
		end

		if not unit:IsDead() and unit:IsEnemy() and unit:IsHostile() and Player:CanSee(unit) and not unit:GetAuras():FindMy(spells.livingBomb):IsUp() then
			livingBomb = unit
		end
	end)

	if livingBomb == nil then
		livingBomb = None
	end

	return livingBomb
end)

-- Decurse
local Decurse = Caffeine.UnitManager:CreateCustomUnit("decurse", function(unit)
	local decurse = nil

	Caffeine.UnitManager:EnumFriends(function(unit)
		if unit:IsDead() then
			return false
		end

		if Player:GetDistance(unit) > 40 then
			return false
		end

		if not Player:CanSee(unit) then
			return false
		end

		if not unit:IsDead() and Player:CanSee(unit) and unit:GetAuras():HasAnyDispelableAura(spells.removeCurse) then
			decurse = unit
		end
	end)

	if decurse == nil then
		decurse = None
	end

	return decurse
end)

-- Spellsteal
local Spellsteal = Caffeine.UnitManager:CreateCustomUnit("spellsteal", function(unit)
	local spellsteal = nil

	Caffeine.UnitManager:EnumEnemies(function(unit)
		if unit:IsDead() then
			return false
		end

		if Player:GetDistance(unit) > 30 then
			return false
		end

		if not Player:CanSee(unit) then
			return false
		end

		if not unit:GetAuras():HasAnyStealableAura() then
			return false
		end

		if not unit:IsDead() and Player:CanSee(unit) and unit:GetAuras():HasAnyStealableAura() then
			spellsteal = unit
		end
	end)

	if spellsteal == nil then
		spellsteal = None
	end

	return spellsteal
end)

-- Molten Armor
PreCombatAPL:AddSpell(spells.moltenArmor
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and not Player:IsAffectingCombat()
			and not Player:GetAuras():FindMy(spells.moltenArmor):IsUp()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Player)
)

-- Conjure Mana Gem
PreCombatAPL:AddSpell(spells.conjureManaGem
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and items.manaGem:GetCharges() < 2
			and not Player:IsAffectingCombat()
			and not Player:IsCastingOrChanneling()
			and not Player:IsMoving()
	end)
	:SetTarget(Player)
)

-- Healthstone
DefaultAPL:AddItem(items.healthstone1
	:UsableIf(function(self)
		return self:IsUsable()
			and not self:IsOnCooldown()
			and Player:GetHP() < Rotation.Config:Read("items_healthStone", 20)
			and Player:IsAffectingCombat()
			and not Player:IsCastingOrChanneling()
			and not Player:IsMoving()
	end)
	:SetTarget(None)
)

-- Healthstone
DefaultAPL:AddItem(items.healthstone2
	:UsableIf(function(self)
		return self:IsUsable()
			and not self:IsOnCooldown()
			and Player:GetHP() < Rotation.Config:Read("items_healthStone", 20)
			and Player:IsAffectingCombat()
			and not Player:IsCastingOrChanneling()
			and not Player:IsMoving()
	end)
	:SetTarget(None)
)

-- Healthstone
DefaultAPL:AddItem(items.healthstone3
	:UsableIf(function(self)
		return self:IsUsable()
			and not self:IsOnCooldown()
			and Player:GetHP() < Rotation.Config:Read("items_healthStone", 20)
			and Player:IsAffectingCombat()
			and not Player:IsCastingOrChanneling()
			and not Player:IsMoving()
	end)
	:SetTarget(None)
)

-- Beserking
DefaultAPL:AddSpell(spells.beserking
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomIsBoss()
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
)

-- Engineering Gloves
DefaultAPL:AddItem(items.inventorySlotGloves
	:UsableIf(function(self)
		local useEngineeringGloves = Rotation.Config:Read("items_engineeringGloves", true)
		return self:IsUsable()
			and not self:IsOnCooldown()
			and useEngineeringGloves
			and Target:Exists()
			and Target:IsHostile()
			and Target:CustomIsBoss()
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
)

-- Mirror Image
DefaultAPL:AddSpell(spells.mirrorImage
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomIsBoss()
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
)

-- Combustion (Potion)
DefaultAPL:AddSpell(spells.combustion
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomIsBoss()
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target)
)

-- Molten Armor
DefaultAPL:AddSpell(spells.moltenArmor
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Target:GetAuras():FindMy(spells.combustion):GetRemainingTime() > 10
			and Player:GetPP() >= 25
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Player)
)

-- Combustion (Auras)
DefaultAPL:AddSpell(spells.combustion
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomIsBoss()
			and Target:GetAuras():FindMy(spells.igniteAura):IsUp()
			and Target:GetAuras():FindMy(spells.livingBomb):IsUp()
			and Target:GetAuras():FindMy(spells.pyroblastAura):IsUp()
			and Player:GetAuras():FindMy(spells.beserking):IsUp()
	end)
	:SetTarget(Target)
)

-- Combustion (Auras)
DefaultAPL:AddSpell(spells.combustion
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomIsBoss()
			and Target:GetAuras():FindMy(spells.igniteAura):IsUp()
			and Target:GetAuras():FindMy(spells.livingBomb):IsUp()
			and Target:GetAuras():FindMy(spells.pyroblastAura):IsUp()
	end)
	:SetTarget(Target)
)

-- Pyro Blast (Hot Streak)
DefaultAPL:AddSpell(spells.pyroblast
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Player:IsFacing(Target)
			and Player:GetAuras():FindMy(spells.hotStreakAura):IsUp()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target)
)

-- Living Bomb
DefaultAPL:AddSpell(spells.livingBomb
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Player:CanSee(Target)
			and Target:CustomTimeToDie() > 12
			and not Target:GetAuras():FindMy(spells.livingBomb):IsUp()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target)
)

-- Spellsteal
DefaultAPL:AddSpell(spells.spellsteal
	:CastableIf(function(self)
		local useSpellsteal = Rotation.Config:Read("spellsteal", true)
		return self:IsKnownAndUsable()
			and self:IsInRange(Spellsteal)
			and useSpellsteal
			and Spellsteal:Exists()
			and Spellsteal:GetAuras():HasAnyStealableAura()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Spellsteal)
)

-- Flame Orb
DefaultAPL:AddSpell(spells.flameOrb
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Target:Exists()
			and Player:CanSee(Target)
			and spells.combustion:OnCooldown()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
)

-- Dragon's Breath
DefaultAPL:AddSpell(spells.dragonsBreath
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Target:Exists()
			and Target:GetDistance(Player) <= 10
			and Target:GetEnemies(12) >= 3
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
)

-- Blast Wave
DefaultAPL:AddSpell(spells.blastWave
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Target:Exists()
			and Target:GetDistance(Player) <= 36
			and Target:GetEnemies(10) >= 3
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
	:OnCast(function(self)
		local position = Target:GetPosition()
		self:Click(position)
	end)
)

-- Flamestrike
DefaultAPL:AddSpell(spells.flamestrike
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Target:Exists()
			and Target:GetDistance(Player) <= 36
			and spells.flamestrike:GetTimeSinceLastCast() > 8
			and Target:GetEnemies(10) >= 3
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
	:OnCast(function(self)
		local position = Target:GetPosition()
		self:Click(position)
	end)
)

-- Living Bomb (AoE)
DefaultAPL:AddSpell(spells.livingBomb
	:CastableIf(function(self)
		local useAoe = Rotation.Config:Read("aoe", true)
		return self:IsKnownAndUsable()
			and self:IsInRange(LivingBomb)
			and useAoe
			and LivingBomb:Exists()
			and LivingBomb:IsHostile()
			and LivingBomb:CustomTimeToDie() > 12
			and not LivingBomb:GetAuras():FindMy(spells.livingBomb):IsUp()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(LivingBomb)
)

-- Mana Gem
DefaultAPL:AddItem(items.manaGem
	:UsableIf(function(self)
		return self:IsUsable()
			and not self:IsOnCooldown()
			and items.manaGem:GetCharges() > 0
			and Player:GetPP() < Rotation.Config:Read("items_manaGem", 90)
			and Player:IsAffectingCombat()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
)

-- Mage Armor
DefaultAPL:AddSpell(spells.mageArmor
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Player:GetPP() < 10
			and not Player:GetAuras():FindMy(spells.mageArmor):IsUp()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Player)
)

-- Fire Ball
DefaultAPL:AddSpell(spells.fireball
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Player:IsFacing(Target)
			and not Player:IsCastingOrChanneling()
			and not Player:IsMoving()
	end)
	:SetTarget(Target)
)

-- Fire Blast
DefaultAPL:AddSpell(spells.fireBlast
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Player:IsFacing(Target)
			and Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target)
)

-- Scorch
DefaultAPL:AddSpell(spells.scorch
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Player:IsFacing(Target)
			and Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target)
)

-- Sync
Module:Sync(function()
	if
		Player:IsDead()
		or IsMounted()
		or UnitInVehicle("player")
		or Player:GetAuras():FindAnyOfMy(spells.refreshmentAuras):IsUp()
		or Player:GetAuras():FindAny(spells.invisibilityAura):IsUp()
		or blacklistUnitById[Target:GetID()]
	then
		return false
	end
	-- Auto Target
	local useAutoTarget = Rotation.Config:Read("autoTarget", true)
	if useAutoTarget and (not Target:Exists() or Target:IsDead()) then
		TargetUnit(HighestHPEnemie:GetGUID())
	end

	-- PreCombatAPL
	PreCombatAPL:Execute()

	if Player:IsAffectingCombat() or Target:IsAffectingCombat() then
		-- DefaultAPL
		DefaultAPL:Execute()
	end
end)

-- Register
Caffeine:Register(Module)
