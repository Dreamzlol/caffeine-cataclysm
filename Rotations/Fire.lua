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

local function hotkeys()
	if IsShiftKeyDown() and spells.blink:IsKnownAndUsable() then
		spells.blink:ForceCast(None)
		Caffeine.Notifications:AddNotification(spells.blink:GetIcon(), "Blink (Hotkey)")
	end
end

-- NPC Blacklist
local blacklistUnitById = {
	[37695] = true, -- Drudge Ghoul: 37695
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
		if hp > highestHP then
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
	local livingBombCount = 0

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

		if unit:GetAuras():FindAny(spells.waterspoutAura):IsUp() then
			return false
		end

		if unit:GetAuras():FindMy(spells.livingBomb):IsUp() then
			livingBombCount = livingBombCount + 1
		elseif not unit:IsDead() and unit:IsEnemy() and unit:IsHostile() and Player:CanSee(unit) then
			livingBomb = unit
		end
	end)

	if livingBombCount >= 2 then
		livingBomb = None
	end

	if livingBomb == nil then
		livingBomb = None
	end

	return livingBomb
end)

local Ignite = Caffeine.UnitManager:CreateCustomUnit("ignite", function(unit)
	local ignite = nil

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

		if not unit:GetAuras():FindMy(spells.igniteAura):IsUp() then
			return false
		end

		if not unit:IsDead() and unit:IsEnemy() and unit:IsHostile() and Player:CanSee(unit) then
			ignite = unit
		end
	end)

	if ignite == nil then
		ignite = None
	end

	return ignite
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
			and (not Player:GetAuras():FindMy(spells.moltenArmor):IsUp() or Player:GetAuras()
				:FindMy(spells.moltenArmor)
				:GetRemainingTime() < 600)
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Player))

-- Arcane Brillance
PreCombatAPL:AddSpell(spells.arcaneBrillance
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and not Player:IsAffectingCombat()
			and (not Player:GetAuras():FindMy(spells.arcaneBrillanceAura):IsUp() or Player:GetAuras()
				:FindMy(spells.arcaneBrillanceAura)
				:GetRemainingTime() < 600)
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Player))

-- Conjure Mana Gem
PreCombatAPL:AddSpell(spells.conjureManaGem
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and items.manaGem:GetCharges() < 2
			and not Player:IsAffectingCombat()
			and not Player:IsCastingOrChanneling()
			and not Player:IsMoving()
	end)
	:SetTarget(Player))

-- ################################################## ITEMS ##################################################
-- Healthstone
DefaultAPL:AddItem(items.healthstone
	:UsableIf(function(self)
		return self:IsUsable()
			and not self:IsOnCooldown()
			and Player:GetHP() < Rotation.Config:Read("items_healthStone", 20)
			and Player:IsAffectingCombat()
			and not Player:IsCastingOrChanneling()
			and not Player:IsMoving()
	end)
	:SetTarget(None)
	:OnUse(function()
		Caffeine.Notifications:AddNotification(items.healthstone:GetIcon(), "Healthstone")
	end))

-- Saronite Bomb
DefaultAPL:AddItem(items.saroniteBomb
	:UsableIf(function(self)
		local useSaroniteBomb = Rotation.Config:Read("items_saroniteBomb", true)
		return self:IsUsable()
			and not self:IsOnCooldown()
			and useSaroniteBomb
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomIsBoss()
			and Player:GetDistance(Target) <= 29
			and not Target:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
	:OnUse(function(self)
		local targetPosition = Target:GetPosition()
		self:Click(targetPosition)
		Caffeine.Notifications:AddNotification(items.saroniteBomb:GetIcon(), "Saronite Bomb")
	end))

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
	:SetTarget(None))

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
	:SetTarget(None))

-- Volcanic Potion
DefaultAPL:AddItem(items.volcanicPotion
	:UsableIf(function(self)
		local volcanicPotion = Rotation.Config:Read("items_volcanicPotion", true)
		return self:IsUsable()
			and not self:IsOnCooldown()
			and volcanicPotion
			and Target:Exists()
			and Target:IsHostile()
			and Target:CustomIsBoss()
			and Player:CanSee(Target)
			and Target:GetAuras():FindMy(spells.igniteAura):IsUp()
			and Target:GetAuras():FindMy(spells.livingBomb):IsUp()
			and (Target:GetAuras():FindMy(spells.pyroblastAura):IsUp() or Target:GetAuras():FindMy(spells.pyroblastAura2):IsUp())
			and not spells.combustion:OnCooldown()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None))

-- Molten Armor
DefaultAPL:AddSpell(spells.moltenArmor
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Player:GetPP() > 25
			and not Player:GetAuras():FindMy(spells.moltenArmor):IsUp()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Player))

-- ################################################## Utilities ##################################################
-- Remove Curse
DefaultAPL:AddSpell(spells.removeCurse
	:CastableIf(function(self)
		local useDecurse = Rotation.Config:Read("decurse", true)
		return self:IsKnownAndUsable()
			and self:IsInRange(Decurse)
			and useDecurse
			and Decurse:Exists()
			and Decurse:GetAuras():HasAnyDispelableAura(spells.removeCurse)
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Decurse)
	:OnCast(function()
		Caffeine.Notifications:AddNotification(spells.removeCurse:GetIcon(), "Remove Curse")
	end))

-- Spellsteal
DefaultAPL:AddSpell(spells.spellsteal
	:CastableIf(function(self)
		local useSpellsteal = Rotation.Config:Read("spellsteal", true)
		return self:IsKnownAndUsable()
			and self:IsInRange(Spellsteal)
			and useSpellsteal
			and Spellsteal:Exists()
			and Spellsteal:IsHostile()
			and Spellsteal:CanSee(Player)
			and Spellsteal:GetAuras():HasAnyStealableAura()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Spellsteal)
	:OnCast(function()
		Caffeine.Notifications:AddNotification(spells.spellsteal:GetIcon(), "Spellsteal")
	end))

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
	:OnCast(function()
		Caffeine.Notifications:AddNotification(spells.pyroblast:GetIcon(), "Pyro Blast (Hot Streak)")
	end))

-- ################################################## AoE ##################################################
-- Fire Blast (AoE - Combustion)
DefaultAPL:AddSpell(spells.fireBlast
	:CastableIf(function(self)
		local useAoE = Rotation.Config:Read("aoe", true)
		return useAoE
			and self:IsKnownAndUsable()
			and self:IsInRange(Ignite)
			and Ignite:Exists()
			and Ignite:IsHostile()
			and Player:CanSee(Ignite)
			and Player:IsFacing(Ignite)
			and Ignite:GetAuras():FindMy(spells.combustionAura):IsUp()
			and Player:GetAuras():FindMy(spells.impactAura):IsUp()
			and Ignite:GetEnemies(12) >= 1
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Ignite)
	:OnCast(function()
		Caffeine.Notifications:AddNotification(spells.fireBlast:GetIcon(), "Fire Blast (AoE)")
	end))

-- Fire Blast (AoE - Pyroblast)
DefaultAPL:AddSpell(spells.fireBlast
	:CastableIf(function(self)
		local useAoE = Rotation.Config:Read("aoe", true)
		return useAoE
			and self:IsKnownAndUsable()
			and self:IsInRange(Ignite)
			and Ignite:Exists()
			and Ignite:IsHostile()
			and Player:CanSee(Ignite)
			and Player:IsFacing(Ignite)
			and (Ignite:GetAuras():FindMy(spells.pyroblastAura):IsUp() or Ignite:GetAuras():FindMy(spells.pyroblastAura2):IsUp())
			and Player:GetAuras():FindMy(spells.impactAura):IsUp()
			and Ignite:GetEnemies(12) >= 1
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Ignite)
	:OnCast(function()
		Caffeine.Notifications:AddNotification(spells.fireBlast:GetIcon(), "Fire Blast (AoE)")
	end))

-- Fire Blast (AoE - Ignite)
DefaultAPL:AddSpell(spells.fireBlast
	:CastableIf(function(self)
		local useAoE = Rotation.Config:Read("aoe", true)
		return useAoE
			and self:IsKnownAndUsable()
			and self:IsInRange(Ignite)
			and Ignite:Exists()
			and Ignite:IsHostile()
			and Player:CanSee(Ignite)
			and Player:IsFacing(Ignite)
			and Ignite:GetAuras():FindMy(spells.igniteAura):IsUp()
			and Player:GetAuras():FindMy(spells.impactAura):IsUp()
			and Ignite:GetEnemies(12) >= 2
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Ignite)
	:OnCast(function()
		Caffeine.Notifications:AddNotification(spells.fireBlast:GetIcon(), "Fire Blast (AoE)")
	end))

-- Dragon's Breath
DefaultAPL:AddSpell(spells.dragonsBreath
	:CastableIf(function(self)
		local useAoE = Rotation.Config:Read("aoe", true)
		return useAoE
			and self:IsKnownAndUsable()
			and Player:GetEnemies(8) >= 3
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
	:OnCast(function()
		Caffeine.Notifications:AddNotification(spells.dragonsBreath:GetIcon(), "Dragon's Breath (AoE)")
	end))

-- Flame Orb (AoE)
DefaultAPL:AddSpell(spells.flameOrb
	:CastableIf(function(self)
		local useAoE = Rotation.Config:Read("aoe", true)
		return useAoE
			and self:IsKnownAndUsable()
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Player:IsFacing(Target)
			and Target:GetEnemies(12) >= 3
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
	:OnCast(function()
		Caffeine.Notifications:AddNotification(spells.flameOrb:GetIcon(), "Flame Orb (AoE)")
	end))

-- Blast Wave (AoE)
DefaultAPL:AddSpell(spells.blastWave
	:CastableIf(function(self)
		local useAoE = Rotation.Config:Read("aoe", true)
		return useAoE
			and self:IsKnownAndUsable()
			and Target:Exists()
			and Player:GetDistance(Target) <= 36
			and Target:GetEnemies(12) >= 2
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
	:OnCast(function(self)
		local position = Target:GetPosition()
		self:Click(position)
		Caffeine.Notifications:AddNotification(spells.blastWave:GetIcon(), "Blast Wave (AoE)")
	end))

-- Flamestrike (AoE)
DefaultAPL:AddSpell(spells.flamestrike
	:CastableIf(function(self)
		local useAoE = Rotation.Config:Read("aoe", true)
		return useAoE
			and self:IsKnownAndUsable()
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:GetEnemies(12) >= 2
			and Player:GetDistance(Target) <= 36
			and spells.flamestrike:GetTimeSinceLastCast() > 8
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
	:OnCast(function(self)
		local position = Target:GetPosition()
		self:Click(position)
		Caffeine.Notifications:AddNotification(spells.flamestrike:GetIcon(), "Flamestrike (AoE)")
	end))

-- Living Bomb (AoE)
DefaultAPL:AddSpell(spells.livingBomb
	:CastableIf(function(self)
		local useAoE = Rotation.Config:Read("aoe", true)
		return useAoE
			and self:IsKnownAndUsable()
			and self:IsInRange(LivingBomb)
			and LivingBomb:Exists()
			and LivingBomb:IsHostile()
			and LivingBomb:CustomTimeToDie() > 12
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(LivingBomb)
	:OnCast(function()
		Caffeine.Notifications:AddNotification(spells.livingBomb:GetIcon(), "Living Bomb (AoE)")
	end))

-- ################################################## Single Target ##################################################
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
	:SetTarget(None))

-- Combustion (Auras)
DefaultAPL:AddSpell(spells.combustion
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomIsBoss()
			and Target:GetAuras():FindMy(spells.igniteAura):IsUp()
			and Target:GetAuras():FindMy(spells.livingBomb):IsUp()
			and (Target:GetAuras():FindMy(spells.pyroblastAura):IsUp() or Target:GetAuras():FindMy(spells.pyroblastAura2):IsUp())
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target)
	:OnCast(function()
		Caffeine.Notifications:AddNotification(spells.combustion:GetIcon(), "Combustion")
	end))

-- Pyro Blast (Opener)
DefaultAPL:AddSpell(spells.pyroblast
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomIsBoss()
			and Target:GetHP() > 95
			and self:GetTimeSinceLastCast() > 5
			and not (Target:GetAuras():FindMy(spells.pyroblastAura):IsUp() or Target:GetAuras():FindMy(spells.pyroblastAura2):IsUp())
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target)
	:OnCast(function()
		Caffeine.Notifications:AddNotification(spells.pyroblast:GetIcon(), "Pyro Blast (Opener)")
	end))

-- Living Bomb
DefaultAPL:AddSpell(spells.livingBomb
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomTimeToDie() > 12
			and not Target:GetAuras():FindMy(spells.livingBomb):IsUp()
			and not Target:GetAuras():FindAny(spells.waterspoutAura):IsUp()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target))

-- Flame Orb (Boss)
DefaultAPL:AddSpell(spells.flameOrb
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Player:IsFacing(Target)
			and Target:CustomIsBoss()
			and spells.combustion:OnCooldown()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
	:OnCast(function()
		Caffeine.Notifications:AddNotification(spells.flameOrb:GetIcon(), "Flame Orb (Boss)")
	end))

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
	:SetTarget(None))

-- Mage Armor
DefaultAPL:AddSpell(spells.mageArmor
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and Player:GetPP() < 10
			and not Player:GetAuras():FindMy(spells.mageArmor):IsUp()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Player)
	:OnCast(function()
		Caffeine.Notifications:AddNotification(spells.mageArmor:GetIcon(), "Mage Armor (Low Mana)")
	end))

-- Fire Ball
DefaultAPL:AddSpell(spells.fireball
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Player:IsFacing(Target)
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target))

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
	:OnCast(function()
		Caffeine.Notifications:AddNotification(spells.scorch:GetIcon(), "Scorch (Movement)")
	end))

-- Fire Blast (Moving)
DefaultAPL:AddSpell(spells.fireBlast
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Player:IsFacing(Target)
			and Player:IsMoving()
			and not Player:GetAuras():FindMy(spells.impactAura):IsUp()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target)
	:OnCast(function()
		Caffeine.Notifications:AddNotification(spells.fireBlast:GetIcon(), "Fire Blast (Movement)")
	end))

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

	-- DefaultAPL
	if Player:IsAffectingCombat() or Target:IsAffectingCombat() then
		hotkeys()
		DefaultAPL:Execute()
	end
end)

-- Register
Caffeine:Register(Module)
