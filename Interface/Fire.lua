local Unlocker, Caffeine, Rotation = ...

-- Loader
if Caffeine.GetClass() ~= "MAGE" then
	return
end

-- Category
Rotation.Category = Caffeine.Interface.Category:New("|cffffffffDreams|cff00B5FFScripts|cffffffff: Fire")

-- Config
Rotation.Config = Rotation.Category.config

-- Initialize the Hotbar Toggle too false
Rotation.Config:Write("aoe", false)
Rotation.Config:Write("decurse", false)
Rotation.Config:Write("spellsteal", false)
Rotation.Config:Write("counterspell", false)
Rotation.Config:Write("combustion", false)
Rotation.Config:Write("autoTarget", false)

Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Mage: Fire (Cataclysm) successfully loaded! Yeeey! :)")
Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Current Version: 1.3.2")
Caffeine:Print(
	"Dreams|cff00B5FFScripts |cffFFFFFF - Need assistance or want to share feedback? Join our Discord community!"
)
Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Discord Link: |cffeb6ee9https://discord.gg/Pm4wQpMDKh")

-- Hotbar
Hotbar = Caffeine.Interface.Hotbar:New({
	name = "Dreams|cff00B5FFScripts",
	options = Rotation.Category,
	buttonCount = 6,
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
	tooltip =
	"Use AoE Spells (Living Bomb, Blast Wave, Flamestrike, Fire Blast, Flame Orb, Dragon's Breath) on enemies around you.",
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
	tooltip = "Automatically removes curses from any party/raid member.",
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

-- Spellsteal
Hotbar:AddButton({
	name = "Toggle Spellsteal",
	texture = "Interface\\ICONS\\Spell_Arcane_Arcane02",
	tooltip = "Steals buffs from nearby enemies when possible.",
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

-- Counterspell
Hotbar:AddButton({
	name = "Toggle Counterspell",
	texture = "Interface\\ICONS\\Spell_Frost_IceShock",
	tooltip = "Counterspell enemies when they casting spells.",
	toggle = true,
	onClick = function()
		local getSetting = Rotation.Config:Read("counterspell", false)
		local setting = not getSetting
		Rotation.Config:Write("counterspell", setting)

		if setting then
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Counterspell Enabled")
		else
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Counterspell Disabled")
		end
	end,
})

-- Hold Combustion
Hotbar:AddButton({
	name = "Toggle Hold Combustion",
	texture = "Interface\\ICONS\\Spell_Fire_SealOfFire",
	tooltip = "Hold of Combustion as long as this Toggle is on. If you turn it off, it will return to functioning normally within the threshold you've set.",
	toggle = true,
	onClick = function()
		local getSetting = Rotation.Config:Read("combustion", false)
		local setting = not getSetting
		Rotation.Config:Write("combustion", setting)

		if setting then
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Hold Combustion Enabled")
		else
			Caffeine:Print("Dreams|cff00B5FFScripts |cffFFFFFF - Hold Combustion Disabled")
		end
	end,
})

-- Auto Target
Hotbar:AddButton({
	name = "Toggle Auto Target",
	texture = "Interface\\ICONS\\Ability_Hunter_MarkedForDeath",
	tooltip = "Automatically targets enemy nearby with the highest health percentage.",
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

-- Items
Rotation.Category:AddSubsection("|cffFFFFFFSpells")
Rotation.Category:Slider({
	category = "spells",
	var = "combustionThreshold",
	name = "Combustion Threshold (Ignite)",
	tooltip = "Use Combustion automatically when the target has an Ignite Tick higher than the chosen threshold.",
	default = 15000,
	min = 0,
	max = 100000,
	step = 500,
})

Rotation.Category:AddSubsection("|cffFFFFFFItems")
Rotation.Category:Slider({
	category = "items",
	var = "healthStone",
	name = "Healthstone",
	tooltip = "Use of Healthstone at specified health percentage.",
	default = 20,
	min = 0,
	max = 100,
	step = 5,
})

Rotation.Category:Slider({
	category = "items",
	var = "manaGem",
	name = "Mana Gem",
	tooltip = "Use of Mana Gem when mana falls below specified percentage.",
	default = 90,
	min = 0,
	max = 100,
	step = 5,
})

Rotation.Category:Checkbox({
	category = "items",
	var = "engineeringGloves",
	name = "Engineering Gloves",
	tooltip = "Use of Engineering Gloves during combat. Target required. (Only Bosses)",
	default = true,
	disabled = false,
})

Rotation.Category:Checkbox({
	category = "items",
	var = "saroniteBomb",
	name = "Saronite Bomb",
	tooltip = "Use of Saronite Bomb during combat. Target required. (Only Bosses)",
	default = true,
	disabled = false,
})

Rotation.Category:Checkbox({
	category = "items",
	var = "volcanicPotion",
	name = "Volcanic Potion",
	tooltip = "Use of Volcanic Potion during combat. Target required. (Only Bosses)",
	default = true,
	disabled = false,
})

Rotation.Category:Register()
