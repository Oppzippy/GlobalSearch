local luaunit = require("luaunit")

require("Tests.WoWEnvironment")

DoWoWFile("Tests/Internal/Search/ShortTextQueryMatcher.lua")
DoWoWFile("Tests/Internal/Search/ShortTextSearchContext.lua")
DoWoWFile("Tests/Internal/Search/SearchProviderCollection.lua")
DoWoWFile("Tests/Internal/Search/SearchProviderRegistry.lua")
DoWoWFile("Tests/Internal/SearchExecutor.lua")
DoWoWFile("Tests/Internal/Util.lua")
DoWoWFile("Tests/Internal/AsyncJob.lua")

os.exit(luaunit.LuaUnit.run())
