---@class ns
local ns = select(2, ...)

---@class SearchProviderCollection
---@field providers table<string, SearchProvider>
local SearchProviderCollectionPrototype = {}

---@param providers table<string, SearchProvider>
---@return SearchProviderCollection
local function CreateSearchProviderCollection(providers)
	local collection = setmetatable({
		providers = providers,
	}, { __index = SearchProviderCollectionPrototype })
	return collection
end

-- We only want to cache decorated item groups as long as the provider itself is caching the
-- original item group
local decoratedItemGroupCache = setmetatable({}, {
	__mode = "k", -- weak key references (https://www.lua.org/pil/17.html)
})

---@return table<string, SearchProvider>
function SearchProviderCollectionPrototype:GetProviders()
	return self.providers
end

---@param providerID string
---@return Task
function SearchProviderCollectionPrototype:GetProviderItemsAsync(providerID)
	return ns.Task.Create(coroutine.create(function()
		local provider = self.providers[providerID]
		if not provider then
			return {}
		end

		--- parameters 3+ get passed as arguments to the first, but lua-ls doesn't seem to recognize this
		---@diagnostic disable-next-line: redundant-parameter
		local success, itemGroup = xpcall(provider.Get, geterrorhandler and geterrorhandler() or print, provider)
		coroutine.yield()

		if success then
			local decoratedItemGroup = decoratedItemGroupCache[itemGroup]
			if not decoratedItemGroup then
				decoratedItemGroup = {}
				-- In addition to adding category and provider information, also validate
				for i, item in ipairs(itemGroup) do
					local isValid, errorMessage = ns.ValidateSearchItem(item)
					if isValid then
						decoratedItemGroup[#decoratedItemGroup + 1] = setmetatable({
							providerID = providerID,
							category = provider.name,
						}, { __index = item })
					else
						-- skip in tests
						if ns.addon and ns.addon:IsDebugMode() then
							---@diagnostic disable-next-line: undefined-global
							if DevTool then
								---@diagnostic disable-next-line: undefined-global
								DevTool:AddData({
									providerID = providerID,
									category = provider.name,
									item = item,
									error = errorMessage,
								})
							end
							ns.addon:Debugf(
								"Invalid item from provider id %s (%s): index %d name %s: %s",
								providerID,
								provider.name or "nil",
								i,
								type(item) == "table" and type(item.name) == "string" and item.name or "nil",
								errorMessage or "nil"
							)
						end
					end
				end
				decoratedItemGroupCache[itemGroup] = decoratedItemGroup
			end

			return decoratedItemGroup
		end
		return {}
	end))
end

local export = { Create = CreateSearchProviderCollection }
if ns then
	ns.SearchProviderCollection = export
end
return export
