local Unlocker, Caffeine, Rotation = ...

-- Loader
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
	manaGem = ItemBook:GetItem(36799),
	healthstone = ItemBook:GetItem(5512),
    saroniteBomb = ItemBook:GetItem(41119),
	volcanicPotion = ItemBook:GetItem(58091),
}
