---@class ns
local ns = select(2, ...)

---@class LimitedTooltip
local LimitedTooltip = {
	AddDoubleLine = function(...) end,
	AddLine = function(...) end,
	AddSpellByID = function(...) end,
	SetAchievementByID = function(...) end,
	SetAction = function(...) end,
	SetArtifactItem = function(...) end,
	SetArtifactPowerByID = function(...) end,
	SetAzeriteEssence = function(...) end,
	SetAzeriteEssenceSlot = function(...) end,
	SetAzeritePower = function(...) end,
	SetBackpackToken = function(...) end,
	SetBagItem = function(...) end,
	SetBagItemChild = function(...) end,
	SetBuybackItem = function(...) end,
	SetCompanionPet = function(...) end,
	SetCompareAzeritePower = function(...) end,
	SetCompareItem = function(...) end,
	SetConduit = function(...) end,
	SetCurrencyByID = function(...) end,
	SetCurrencyToken = function(...) end,
	SetCurrencyTokenByID = function(...) end,
	SetEquipmentSet = function(...) end,
	SetEnhancedConduit = function(...) end,
	SetExistingSocketGem = function(...) end,
	SetGuildBankItem = function(...) end,
	SetHeirloomByItemID = function(...) end,
	SetHyperlink = function(...) end,
	SetInboxItem = function(...) end,
	SetInstanceLockEncountersComplete = function(...) end,
	SetInventoryItem = function(...) end,
	SetInventoryItemByID = function(...) end,
	SetItemByID = function(...) end,
	SetItemKey = function(...) end,
	SetLFGDungeonReward = function(...) end,
	SetLFGDungeonShortageReward = function(...) end,
	SetLootCurrency = function(...) end,
	SetLootItem = function(...) end,
	SetLootRollItem = function(...) end,
	SetMerchantCostItem = function(...) end,
	SetMerchantItem = function(...) end,
	SetMountBySpellID = function(...) end,
	SetOwnedItemByID = function(...) end,
	SetPetAction = function(...) end,
	SetPossession = function(...) end,
	SetPvpBrawl = function(...) end,
	SetPvpTalent = function(...) end,
	SetQuestCurrency = function(...) end,
	SetQuestItem = function(...) end,
	SetQuestLogCurrency = function(...) end,
	SetQuestLogItem = function(...) end,
	SetQuestLogRewardSpell = function(...) end,
	SetQuestLogSpecialItem = function(...) end,
	SetQuestPartyProgress = function(...) end,
	SetQuestRewardSpell = function(...) end,
	SetRecipeRankInfo = function(...) end,
	SetRecipeReagentItem = function(...) end,
	SetRecipeResultItem = function(...) end,
	SetRuneforgeResultItem = function(...) end,
	SetSendMailItem = function(...) end,
	SetShapeshift = function(...) end,
	SetSocketedItem = function(...) end,
	SetSocketedRelic = function(...) end,
	SetSocketGem = function(...) end,
	SetSpecialPvpBrawl = function(...) end,
	SetSpellBookItem = function(...) end,
	SetSpellByID = function(...) end,
	SetTalent = function(...) end,
	SetText = function(...) end,
	SetTotem = function(...) end,
	SetToyByItemID = function(...) end,
	SetTradePlayerItem = function(...) end,
	SetTradeTargetItem = function(...) end,
	SetTrainerService = function(...) end,
	SetTransmogrifyItem = function(...) end,
	SetUnit = function(...) end,
	SetUnitAura = function(...) end,
	SetUnitBuff = function(...) end,
	SetUnitDebuff = function(...) end,
	SetUpgradeItem = function(...) end,
	SetVoidDepositItem = function(...) end,
	SetVoidItem = function(...) end,
	SetVoidWithdrawalItem = function(...) end,
	SetWeeklyReward = function(...) end,
}

local cache = {}
---@param tooltip GameTooltip
---@return LimitedTooltip
local function Limit(tooltip)
	if not cache[tooltip] then
		local limitedTooltip = {}
		for method in next, LimitedTooltip do
			local func = tooltip[method]
			limitedTooltip[method] = function(_, ...)
				func(tooltip, ...)
			end
		end
		cache[tooltip] = ns.Util.ReadOnlyTable(limitedTooltip)
	end
	return cache[tooltip]
end

local export = { Limit = Limit }
if ns then
	ns.LimitedTooltip = export
end
return export
