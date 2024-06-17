local Unlocker, Caffeine, Rotation = ...

-- Loader
if Caffeine.GetSpec() ~= 2 then
	return
end

if Caffeine.GetClass() ~= "MAGE" then
	return
end

-- Category
Rotation.Category = Caffeine.Interface.Category:New("|cffffffffDreams|cff00B5FFScripts|cffffffff: Fire")

-- Config
Rotation.Config = Rotation.Category.config

-- Initialize the Hotbar Toggle too false
Rotation.Config:Write("aoe", false)
Rotation.Config:Write("autoTarget", false)
Rotation.Config:Write("decurse", false)
Rotation.Config:Write("scorch", false)
Rotation.Config:Write("spellsteal", false)

Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Hello! Rotation successfully initialized.")
Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Version: 2.0.8")
Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - If you need any help or have suggestions.")
Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Discord: |cffeb6ee9https://discord.gg/Pm4wQpMDKh")

-- Hotbar
Hotbar = Caffeine.Interface.Hotbar:New({
	name = "Dreams|cff00B5FFScripts",
	options = Rotation.Category,
	buttonCount = 3,
})

-- Toggle Rotation
Hotbar:AddButton({
	name = "Toggle Rotation",
	texture = "Interface\\ICONS\\Ability_Rogue_FindWeakness",
	tooltip = "Enable Rotation",
	toggle = true,
	onClick = function()
		Module = Caffeine:FindModule("fire")
		if Module then
			Module.enabled = not Module.enabled
			if Module.enabled then
				Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Fire Enabled")
			else
				Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Fire Disabled")
			end
		end
	end,
})

-- AoE
Hotbar:AddButton({
	name = "Toggle AoE",
	texture = "Interface\\ICONS\\Ability_Mage_LivingBomb",
	tooltip = "Use Living Bomb on enemies which are not your Target",
	toggle = true,
	onClick = function()
		local getSetting = Rotation.Config:Read("aoe", false)
		local setting = not getSetting
		Rotation.Config:Write("aoe", setting)

		if setting then
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - AoE Enabled")
		else
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - AoE Disabled")
		end
	end,
})

-- Remove Decurse
Hotbar:AddButton({
	name = "Toggle Remove Curse",
	texture = "Interface\\ICONS\\Spell_Nature_RemoveCurse",
	tooltip = "Use Remove Curse if anyone has a Curse active",
	toggle = true,
	onClick = function()
		local getSetting = Rotation.Config:Read("decurse", false)
		local setting = not getSetting
		Rotation.Config:Write("decurse", setting)

		if setting then
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Remove Curse Enabled")
		else
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Remove Curse Disabled")
		end
	end,
})

-- Scorch
Hotbar:AddButton({
	name = "Toggle Scorch",
	texture = "Interface\\ICONS\\Spell_Fire_SoulBurn",
	tooltip = "Use Scorch to apply the Crit Debuff. Dont use it if you have a Warlock in Raid",
	toggle = true,
	onClick = function()
		local getSetting = Rotation.Config:Read("scorch", false)
		local setting = not getSetting
		Rotation.Config:Write("scorch", setting)

		if setting then
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Scorch Enabled")
		else
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Scorch Disabled")
		end
	end,
})

-- Spellsteal
Hotbar:AddButton({
	name = "Toggle Spellsteal",
	texture = "Interface\\ICONS\\Spell_Arcane_Arcane02",
	tooltip = "Use Spellsteal too steal buffs from nearby enemies",
	toggle = true,
	onClick = function()
		local getSetting = Rotation.Config:Read("spellsteal", false)
		local setting = not getSetting
		Rotation.Config:Write("spellsteal", setting)

		if setting then
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Spellsteal Enabled")
		else
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Spellsteal Disabled")
		end
	end,
})

-- Auto Target
Hotbar:AddButton({
	name = "Toggle Auto Target",
	texture = "Interface\\ICONS\\Ability_Hunter_MarkedForDeath",
	tooltip = "Use Auto Target, it will automatically Auto Target the highest enemie nearby",
	toggle = true,
	onClick = function()
		local getSetting = Rotation.Config:Read("autoTarget", false)
		local setting = not getSetting
		Rotation.Config:Write("autoTarget", setting)

		if setting then
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Auto Target Enabled")
		else
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Auto Target Disabled")
		end
	end,
})

-- Spells
Rotation.Category:AddSubsection("|cffFFFFFFSpells")
Rotation.Category:Checkbox({
	category = "spells",
	var = "flamestrike",
	name = "Flamestrike",
	tooltip = "Use of Flamestrike in the aoe rotation. Beta feature use with caution, disable it if you have problems",
	default = true,
	disabled = false,
})

-- Items
Rotation.Category:AddSubsection("|cffFFFFFFItems")
Rotation.Category:Slider({
	category = "items",
	var = "healthStone",
	name = "Healthstone",
	tooltip = "Use Healthstone if you below Health Percentage",
	default = 20,
	min = 0,
	max = 100,
	step = 5,
})

Rotation.Category:Slider({
	category = "items",
	var = "manaGem",
	name = "Mana Gem",
	tooltip = "Use Mana Gem if you below Mana Percentage",
	default = 90,
	min = 0,
	max = 100,
	step = 5,
})

Rotation.Category:Checkbox({
	category = "items",
	var = "engineeringGloves",
	name = "Engineering Gloves",
	tooltip = "Use of Engineering Gloves in the rotation. Requires Target",
	default = true,
	disabled = false,
})

Rotation.Category:Checkbox({
	category = "items",
	var = "saroniteBomb",
	name = "Saronite Bomb",
	tooltip = "Enable or disable the use of Saronite Bomb in the rotation. Requires Target",
	default = true,
	disabled = false,
})

-- Options
Rotation.Category:AddSubsection("|cffFFFFFFOptions")
Rotation.Category:Checkbox({
	category = "options",
	var = "dungeonLogic",
	name = "Dungeon Logic (Gamma)",
	tooltip = "Use of Dungeon Logic in Gamma Dungeons. This will use Ice Lance at Mirror Images and Web Wraps",
	default = true,
	disabled = false,
})

Rotation.Category:Register()
