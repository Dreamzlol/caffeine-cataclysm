local Unlocker, Caffeine, Rotation = ...

-- Loader
if Caffeine.GetSpec() ~= 2 then
	return
end

if Caffeine.GetClass() ~= "MAGE" then
	return
end

local ItemBook = Caffeine.Globals.ItemBook

-- Get ItemID from Inventory Slot
local function getItemID(slot)
	local ItemID = GetInventoryItemID("player", slot)
	return ItemID
end

-- Items
Rotation.Items = {
	inventorySlotGloves = ItemBook:GetItem(getItemID(10)),
	invetorySlotBoots = ItemBook:GetItem(getItemID(8)),
	manaGem = ItemBook:GetItem(33312),
	saroniteBomb = ItemBook:GetItem(41119),
	shardIfTheCrystalHeart = ItemBook:GetItem(48722),
	healthstone1 = ItemBook:GetItem(36892),
	healthstone2 = ItemBook:GetItem(36893),
	healthstone3 = ItemBook:GetItem(36894),
}
