local Unlocker, Caffeine, Rotation = ...

-- Loader
if Caffeine.GetSpec() ~= 2 then
	return
end

if Caffeine.GetClass() ~= "MAGE" then
	return
end

local SpellBook = Caffeine.Globals.SpellBook

Rotation.Spells = {
	-- Buffs
	moltenFire = SpellBook:GetSpell(43046),

	-- Fire Spells
	fireBlast = SpellBook:GetSpell(42873),
	fireball = SpellBook:GetSpell(42833),
	pyroblast = SpellBook:GetSpell(42891),
	livingBomb = SpellBook:GetSpell(55360),
	flamestrike = SpellBook:GetSpell(42926),
	combustion = SpellBook:GetSpell(11129),
	scorch = SpellBook:GetSpell(42859),

	-- Frost Spells
	iceLance = SpellBook:GetSpell(42914),
	iceBlock = SpellBook:GetSpell(45438),

	-- Arcane Spells
	conjureManaGem = SpellBook:GetSpell(42985),
	counterspell = SpellBook:GetSpell(2139),
	mirrorImage = SpellBook:GetSpell(55342),
	evocation = SpellBook:GetSpell(12051),
	spellsteal = SpellBook:GetSpell(30449),
	removeCurse = SpellBook:GetSpell(475),
	invisibility = SpellBook:GetSpell(66),

	-- Racials
	beserking = SpellBook:GetSpell(26297),

	-- Auras
	hotStreakAura = SpellBook:GetSpell(48108),
	critDebuffAuras = SpellBook:GetList(22959, 12873, 12872, 11095, 22959, 17794, 17798, 17799, 17800, 18271, 18272, 18273, 18274),
	combustionAura = SpellBook:GetSpell(28682),
	shroudOfTheOccult = SpellBook:GetSpell(70768),
	shroudOfSpellWarding = SpellBook:GetSpell(72066),
	bloodBoilAura = SpellBook:GetSpell(72385),
	luckOfTheDrawAura = SpellBook:GetSpell(72221),
	refreshmentAuras = SpellBook:GetList(43183, 57073),
	invisibilityAura = SpellBook:GetSpell(66),
	successInvisibilityAura = SpellBook:GetSpell(32612),
	inoculatedAura = SpellBook:GetSpell(69291),
	unchainedMagicAura = SpellBook:GetSpell(69762),
	instabilityAura = SpellBook:GetSpell(69766),
	pungentBlight = SpellBook:GetSpell(69195),
	tearGas = SpellBook:GetSpell(71617),
}
