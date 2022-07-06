---@class ns
local _, ns = ...

local tooltipWhitelist = {
	"AddDoubleLine",
	"AddLine",
	"AddSpellByID",
	"SetAchievementByID",
	"SetAction",
	"SetArtifactItem",
	"SetArtifactPowerByID",
	"SetAzeriteEssence",
	"SetAzeriteEssenceSlot",
	"SetAzeritePower",
	"SetBackpackToken",
	"SetBagItem",
	"SetBagItemChild",
	"SetBuybackItem",
	"SetCompanionPet",
	"SetCompareAzeritePower",
	"SetCompareItem",
	"SetConduit",
	"SetCurrencyByID",
	"SetCurrencyToken",
	"SetCurrencyTokenByID",
	"SetEquipmentSet",
	"SetEnhancedConduit",
	"SetExistingSocketGem",
	"SetGuildBankItem",
	"SetHeirloomByItemID",
	"SetHyperlink",
	"SetInboxItem",
	"SetInstanceLockEncountersComplete",
	"SetInventoryItem",
	"SetInventoryItemByID",
	"SetItemByID",
	"SetItemKey",
	"SetLFGDungeonReward",
	"SetLFGDungeonShortageReward",
	"SetLootCurrency",
	"SetLootItem",
	"SetLootRollItem",
	"SetMerchantCostItem",
	"SetMerchantItem",
	"SetMountBySpellID",
	"SetOwnedItemByID",
	"SetPetAction",
	"SetPossession",
	"SetPvpBrawl",
	"SetPvpTalent",
	"SetQuestCurrency",
	"SetQuestItem",
	"SetQuestLogCurrency",
	"SetQuestLogItem",
	"SetQuestLogRewardSpell",
	"SetQuestLogSpecialItem",
	"SetQuestPartyProgress",
	"SetQuestRewardSpell",
	"SetRecipeRankInfo",
	"SetRecipeReagentItem",
	"SetRecipeResultItem",
	"SetRuneforgeResultItem",
	"SetSendMailItem",
	"SetShapeshift",
	"SetSocketedItem",
	"SetSocketedRelic",
	"SetSocketGem",
	"SetSpecialPvpBrawl",
	"SetSpellBookItem",
	"SetSpellByID",
	"SetTalent",
	"SetText",
	"SetTotem",
	"SetToyByItemID",
	"SetTradePlayerItem",
	"SetTradeTargetItem",
	"SetTrainerService",
	"SetTransmogrifyItem",
	"SetUnit",
	"SetUnitAura",
	"SetUnitBuff",
	"SetUnitDebuff",
	"SetUpgradeItem",
	"SetVoidDepositItem",
	"SetVoidItem",
	"SetVoidWithdrawalItem",
	"SetWeeklyReward",
}


---@type fun(tooltip: GameTooltip): unknown
local Limit
do
	local cache = {}
	Limit = function(tooltip)
		if not cache[tooltip] then
			local limitedTooltip = {}
			for _, method in next, tooltipWhitelist do
				local func = tooltip[method]
				limitedTooltip[method] = function(_, ...)
					func(tooltip, ...)
				end
			end
			cache[tooltip] = ns.Util.ReadOnlyTable(limitedTooltip)
		end
		return cache[tooltip]
	end
end

local export = { Limit = Limit }
if ns ~= nil then
	ns.LimitedTooltip = export
end
return export
