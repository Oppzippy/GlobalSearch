local luaunit = require("luaunit")

require("Tests.Internal.Search.ShortTextQueryMatcher")
require("Tests.Internal.Search.ShortTextSearchContext")
require("Tests.Internal.Search.SearchProviderCollection")
require("Tests.Internal.Search.SearchProviderRegistry")
require("Tests.Internal.Util")

os.exit(luaunit.LuaUnit.run())
