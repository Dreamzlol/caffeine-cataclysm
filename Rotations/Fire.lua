local Unlocker, Caffeine, Rotation = ...

-- Loader
if Caffeine.GetSpec() ~= 2 then
	return
end

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

local HighestEnemy = Caffeine.UnitManager:CreateCustomUnit("highest", function(unit)
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

local DungeonLogic = Caffeine.UnitManager:CreateCustomUnit("dungeonLogic", function(unit)
	local dungeonLogic = nil

	Caffeine.UnitManager:EnumUnits(function(unit)
		if unit:IsDead() then
			return false
		end

		if Player:GetDistance(unit) > 36 then
			return false
		end

		if not Player:CanSee(unit) then
			return false
		end

		if not unit:IsEnemy() then
			return false
		end

		if not unit:IsHostile() then
			return false
		end

		if not unit:GetID() == 28619 or not unit:GetName() == "Mirror Image" then
			return false
		end

		if Player:CanSee(unit) and Player:IsFacing(unit) and (unit:GetID() == 28619 or unit:GetName() == "Mirror Image") then
			dungeonLogic = unit
		end
	end)

	if dungeonLogic == nil then
		dungeonLogic = None
	end

	return dungeonLogic
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

		if unit:GetID() == 36609 and unit:GetHP() < 99 then
			return false
		end

		if unit:GetAuras():FindAny(spells.shroudOfTheOccult):IsUp() or unit:GetAuras():FindAny(spells.shroudOfSpellWarding):IsUp() then
			return false
		end

		if unit:IsCreatureType("Critter") then
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

-- Boss Behavior
local function BossBehaviors()
	-- Icecrown Citadel
	if
		Player:GetAuras():FindAny(spells.successInvisibilityAura):IsUp()
		and Player:GetAuras():FindAny(spells.successInvisibilityAura):GetRemainingTime() <= 17
	then
		local i = 1
		repeat
			local name = UnitBuff("player", i)
			if name == "Invisibility" then
				CancelUnitBuff("player", i)
				break
			end
			i = i + 1
		until not name
	end

	-- Professor Putricide (36678)
	if Target:GetID() == 36678 then
		-- Stop Casting if Target is casting Tear Gas
		if Player:GetAuras():FindAny(spells.invisibilityAura):IsUp() or Target:GetCastingOrChannelingSpell() == spells.tearGas then
			SpellStopCasting()
		end
	end

	-- Festergut (36626)
	if Target:GetID() == 36626 then
		-- Canceling Ice Block if its active and when the target is not casting Pungent Blight
		if Player:GetAuras():FindAny(spells.iceBlock):IsUp() and not Target:GetCastingOrChannelingSpell() == spells.pungentBlight then
			local i = 1
			repeat
				local name = UnitBuff("player", i)
				if name == "Ice Block" then
					CancelUnitBuff("player", i)
					break
				end
				i = i + 1
			until not name
		end
	end

	-- Sindragosa Logic (36853)
	if Target:GetID() == 36853 then
		-- Phase 3: Canceling Ice Block if its active and Unchained Magic is not active
		if Target:GetHP() <= 35 and not Player:GetAuras():FindAny(spells.unchainedMagicAura):IsUp() and Player:GetAuras():FindAny(spells.iceBlock):IsUp() then
			local i = 1
			repeat
				local name = UnitBuff("player", i)
				if name == "Ice Block" then
					CancelUnitBuff("player", i)
					break
				end
				i = i + 1
			until not name
		end

		-- Phase 3: if Unchained Debuff we Cancel Cast and Casting Iceblock
		if Target:GetHP() <= 35 and Player:GetAuras():FindAny(spells.unchainedMagicAura):IsUp() and not Player:GetAuras():FindAny(spells.invisibilityAura) then
			SpellStopCasting()
			spells.iceBlock:ForceCast(None)
		end

		-- Stop Casting after 1 Stack of Instability
		if Player:GetAuras():FindAny(spells.unchainedMagicAura):IsUp() then
			SpellStopCasting()
		end
	end

	return false
end

-- Rotation Behavior
local function RotationBehaviors()
	-- if Hot Streak is active and we started a new cast, cancling current cast. This is preventing overlapping HotStreak Buffs
	if Player:GetAuras():FindMy(spells.hotStreakAura):IsUp() then
		if Player:GetCastingOrChannelingSpell() == spells.fireball and Player:GetChannelOrCastPercentComplete() <= 30 then
			SpellStopCasting()
		end
	end
end

-- Molten Fire
PreCombatAPL:AddSpell(spells.moltenFire
	:CastableIf(function(self)
		return self:IsKnownAndUsable() and not Player:GetAuras():FindMy(spells.moltenFire):IsUp() and not Player:IsCastingOrChanneling()
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
	:SetTarget(None))

DefaultAPL:AddItem(items.healthstone2
	:UsableIf(function(self)
		return self:IsUsable()
			and not self:IsOnCooldown()
			and Player:GetHP() < Rotation.Config:Read("items_healthStone", 20)
			and Player:IsAffectingCombat()
			and not Player:IsCastingOrChanneling()
			and not Player:IsMoving()
	end)
	:SetTarget(None))

DefaultAPL:AddItem(items.healthstone3
	:UsableIf(function(self)
		return self:IsUsable()
			and not self:IsOnCooldown()
			and Player:GetHP() < Rotation.Config:Read("items_healthStone", 20)
			and Player:IsAffectingCombat()
			and not Player:IsCastingOrChanneling()
			and not Player:IsMoving()
	end)
	:SetTarget(None))

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

-- DungeonLogic: Web Wrap and Mirror Images
DefaultAPL:AddSpell(spells.iceLance
	:CastableIf(function(self)
		if not Player:GetAuras():FindAny(spells.luckOfTheDrawAura):IsUp() then
			return false
		end
		local useDungeonLogic = Rotation.Config:Read("options_dungeonLogic", true)
		return self:IsKnownAndUsable() and self:IsInRange(DungeonLogic) and useDungeonLogic and DungeonLogic:Exists() and Player:IsFacing(DungeonLogic)
	end)
	:SetTarget(DungeonLogic))

-- Invisibility: Professor Putricide
DefaultAPL:AddSpell(spells.invisibility
	:CastableIf(function(self)
		return self:IsKnownAndUsable() and Target:Exists() and Target:GetCastingOrChannelingSpell() == spells.tearGas
	end)
	:SetTarget(Player)
	:PreCast(function(self)
		self:ForceCast(None)
		Caffeine.Notifications:AddNotification(spells.invisibility:GetIcon(), "Invisibility (Tear Gas)")
	end))

-- Ice Block: Deathbringer Saurfang
DefaultAPL:AddSpell(spells.iceBlock
	:CastableIf(function(self)
		return self:IsKnownAndUsable() and Target:Exists() and Player:GetAuras():FindAny(spells.bloodBoilAura):IsUp()
	end)
	:SetTarget(Player)
	:OnCast(function(self)
		Caffeine.Notifications:AddNotification(spells.iceBlock:GetIcon(), "Ice Block (Blood Boil)")
	end))

-- Ice Block: Festergut
DefaultAPL:AddSpell(spells.iceBlock
	:CastableIf(function(self)
		return self:IsKnownAndUsable() and Target:Exists() and Target:GetCastingOrChannelingSpell() == spells.pungentBlight
	end)
	:SetTarget(Player)
	:OnCast(function(self)
		Caffeine.Notifications:AddNotification(spells.iceBlock:GetIcon(), "Ice Block (Pungent Blight)")
	end))

-- Mirror Image
DefaultAPL:AddSpell(spells.mirrorImage
	:CastableIf(function(self)
		return spells.mirrorImage:IsKnownAndUsable()
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomIsBoss()
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None))

-- Scorch
DefaultAPL:AddSpell(spells.scorch
	:CastableIf(function(self)
		local useScorch = Rotation.Config:Read("scorch", true)
		return self:IsKnownAndUsable()
			and self:IsInRange(Target)
			and useScorch
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Player:IsFacing(Target)
			and spells.scorch:GetTimeSinceLastCast() > 4
			and Target:CustomIsBoss()
			and not Target:GetAuras():FindAnyOf(spells.critDebuffAuras):IsUp()
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Target))

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
	end))

-- Combustion
DefaultAPL:AddSpell(spells.combustion
	:CastableIf(function(self)
		return self:IsKnownAndUsable()
			and not self:IsOnCooldown()
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and spells.combustion:GetTimeSinceLastCast() > 120
			and Target:CustomIsBoss()
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(Player))

-- Shard of the Crystal Heart
DefaultAPL:AddItem(items.shardIfTheCrystalHeart
	:UsableIf(function(self)
		return self:IsEquippedAndUsable()
			and not self:IsOnCooldown()
			and Target:Exists()
			and Target:IsHostile()
			and Player:CanSee(Target)
			and Target:CustomIsBoss()
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None))

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
	:SetTarget(Target))

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
	:SetTarget(Decurse))

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
	:SetTarget(Spellsteal))

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
	:SetTarget(Target))

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
	:SetTarget(Target))

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
	:SetTarget(LivingBomb))

-- Flamestrike
DefaultAPL:AddSpell(spells.flamestrike
	:CastableIf(function(self)
		local useFlamestrike = Rotation.Config:Read("spells_flamestrike", true)
		local useAoe = Rotation.Config:Read("aoe", true)
		return self:IsKnownAndUsable()
			and useFlamestrike
			and useAoe
			and Target:Exists()
			and Target:GetDistance(Player) <= 36
			and spells.flamestrike:GetTimeSinceLastCast() > 8
			and Target:GetEnemies(10) >= 4
			and not Player:IsMoving()
			and not Player:IsCastingOrChanneling()
	end)
	:SetTarget(None)
	:OnCast(function(self)
		local position = Target:GetPosition()
		self:Click(position)
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
			and not Player:IsCastingOrChanneling()
			and not Player:IsMoving()
	end)
	:SetTarget(Target))

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

	-- Rotation Behavior
	RotationBehaviors()

	-- Boss Behavior
	BossBehaviors()

	-- Auto Target
	local useAutoTarget = Rotation.Config:Read("autoTarget", true)
	if useAutoTarget and (not Target:Exists() or Target:IsDead()) then
		TargetUnit(HighestEnemy:GetGUID())
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
