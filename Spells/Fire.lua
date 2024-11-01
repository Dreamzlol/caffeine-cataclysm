local Unlocker, Caffeine, Rotation = ...

-- Loader
if Caffeine.GetClass() ~= "MAGE" then
	return
end

local SpellBook = Caffeine.Globals.SpellBook

Rotation.Spells = {
	-- Buffs
	moltenArmor = SpellBook:GetSpell(30482),
	mageArmor = SpellBook:GetSpell(6117),
	arcaneBrillance = SpellBook:GetSpell(1459),

	-- Fire Spells
	fireBlast = SpellBook:GetSpell(2136),
	fireball = SpellBook:GetSpell(133),
	pyroblast = SpellBook:GetSpell(11366),
	livingBomb = SpellBook:GetSpell(44457),
	flamestrike = SpellBook:GetSpell(2120),
	combustion = SpellBook:GetSpell(11129),
	scorch = SpellBook:GetSpell(2948),
	flameOrb = SpellBook:GetSpell(82731),
	blastWave = SpellBook:GetSpell(11113),
	dragonsBreath = SpellBook:GetSpell(31661),

	-- Frost Spells
	iceLance = SpellBook:GetSpell(42914),
	iceBlock = SpellBook:GetSpell(45438),

	-- Arcane Spells
	conjureManaGem = SpellBook:GetSpell(759),
	counterspell = SpellBook:GetSpell(2139),
	mirrorImage = SpellBook:GetSpell(55342),
	evocation = SpellBook:GetSpell(12051),
	spellsteal = SpellBook:GetSpell(30449),
	removeCurse = SpellBook:GetSpell(475),
	invisibility = SpellBook:GetSpell(66),
	blink = SpellBook:GetSpell(1953),

	-- Racials
	beserking = SpellBook:GetSpell(26297),

	-- Auras
	hotStreakAura = SpellBook:GetSpell(48108),
	igniteAura = SpellBook:GetSpell(413841),
	pyroblastAura = SpellBook:GetSpell(11366),
	pyroblastAura2 = SpellBook:GetSpell(92315),
	combustionAura = SpellBook:GetSpell(28682),
	luckOfTheDrawAura = SpellBook:GetSpell(72221),
	refreshmentAuras = SpellBook:GetList(80169, 87959, 80167),
	invisibilityAura = SpellBook:GetSpell(66),
	successInvisibilityAura = SpellBook:GetSpell(32612),
	impactAura = SpellBook:GetSpell(64343),
	arcaneBrillanceAura = SpellBook:GetSpell(79058),

	-- Living Bomb Blacklist Spells
	waterspoutAura = SpellBook:GetSpell(75683),

	-- Counterspell Blacklist Spells
	releaseAberrations = SpellBook:GetSpell(77569)
}
