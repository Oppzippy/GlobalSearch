local namespace = {}
---@param path string
function DoWoWFile(path)
	local func, err = loadfile(path)
	if err then
		error(err)
	end
	if not func then
		error(string.format("error loading %s: function is nil", path))
	end
	func("GlobalSearch", namespace)
end

_G.bit = require("bit") -- requires BitOp library

--- Internal
DoWoWFile("Internal/Util.lua")
DoWoWFile("Internal/Unicode/UnicodeMatcher.lua")
DoWoWFile("Internal/Unicode/Unicode.lua")
DoWoWFile("Internal/Unicode/UTF8.lua")
DoWoWFile("Internal/Search/CombinedSearchContext.lua")
DoWoWFile("Internal/Search/FullTextSearchContext.lua")
DoWoWFile("Internal/Search/FullTextWordIndex.lua")
DoWoWFile("Internal/Search/QueryMatcher.lua")
DoWoWFile("Internal/Search/SearchContext.lua")
DoWoWFile("Internal/Search/ShortTextQueryMatcher.lua")
DoWoWFile("Internal/Search/ShortTextSearchContext.lua")
DoWoWFile("Internal/KeybindingRegistry.lua")
DoWoWFile("Internal/SearchContextCache.lua")
DoWoWFile("Internal/SearchExecutor.lua")
DoWoWFile("Internal/SearchItem.lua")
DoWoWFile("Internal/SearchProvider.lua")
DoWoWFile("Internal/SearchProviderCollection.lua")
DoWoWFile("Internal/SearchProviderRegistry.lua")
DoWoWFile("Internal/Task.lua")
